defmodule Lucuma.Billing do
  @moduledoc """
  The Billing context.
  """
  require Logger
  import Ecto.Query, warn: false
  alias Lucuma.Repo
  alias Lucuma.Accounts.Company
  alias Lucuma.Billing.SubscriptionForm
  alias Lucuma.Billing.PaymentPlan

  def change_subscription_form(%SubscriptionForm{} = registration_form) do
    SubscriptionForm.changeset(registration_form, %{})
  end

  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  def get_payment_plan(plan_id) do
    {:ok, payment_plan} = Stripe.Plan.retrieve(plan_id)
    payment_plan
  end

  def subscription_active?(company) do
    if company.stripe_subscription_id do
      subscription = get_current_subscription(company.stripe_subscription_id)

      if subscription do
        if subscription.status == "active" do
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def get_current_subscription(nil) do
    nil
  end

  def get_current_subscription(stripe_subscription_id) do
    {:ok, subscription} = Stripe.Subscription.retrieve(stripe_subscription_id)
    subscription
  end

  def plans do
    {:ok, %Stripe.List{data: [%Stripe.Product{id: product_id}]}} = Stripe.Product.list()
    Stripe.Plan.list(%{product: product_id})
  end

  def create_subscription(
        user,
        company,
        %{"id" => stripe_payment_plan_id, "stripeToken" => stripe_credit_card_token} = form_params
      ) do
    changeset = SubscriptionForm.changeset(%SubscriptionForm{}, form_params)

    if changeset.valid? do
      subscription_form = Ecto.Changeset.apply_changes(changeset)

      multi_result =
        Ecto.Multi.new()
        |> Ecto.Multi.run(:create_stripe_customer, fn repo, previous_steps ->
          Logger.debug("Creating Stripe customer")

          create_stripe_customer(user, company, stripe_credit_card_token)
        end)
        |> Ecto.Multi.run(:create_stripe_subscription, fn _repo,
                                                          %{
                                                            create_stripe_customer:
                                                              stripe_customer
                                                          } ->
          Logger.debug("Creating Stripe Subscription")

          stripe_response = create_stripe_subscription(stripe_customer, stripe_payment_plan_id)
          Logger.info(inspect(stripe_response))
          stripe_response
        end)
        |> Ecto.Multi.run(:check_initial_payment_succeeded, fn %{
                                                                 create_stripe_customer:
                                                                   stripe_customer,
                                                                 create_stripe_subscription:
                                                                   stripe_subscription
                                                               } ->
          # See https://stripe.com/docs/api/subscriptions/object#subscription_object-status
          # Even though the subscription was created successfully, I wan't to check that the
          # payment/charge went through. If not we want to return an error
          if stripe_subscription.status == "active" do
            {:ok, stripe_subscription.status}
          else
            {:error, stripe_subscription.status}
          end
        end)
        |> Ecto.Multi.update(:update_company_with_stripe_data, fn %{
                                                                    create_stripe_customer:
                                                                      stripe_customer,
                                                                    create_stripe_subscription:
                                                                      stripe_subscription,
                                                                    check_initial_payment_succeeded:
                                                                      subscription_status
                                                                  } ->
          # create_payment_plan_record(
          #   company,
          #   stripe_customer,
          #   stripe_subscription,
          #   stripe_payment_plan_id
          # )

          changeset =
            Company.changeset(company, %{
              stripe_customer_id: stripe_customer.id,
              stripe_payment_plan_id: stripe_payment_plan_id,
              stripe_subscription_id: stripe_subscription.id
            })

          changeset
        end)
        |> Repo.transaction()

      case multi_result do
        {:ok, steps} ->
          Logger.info("Subscription created successfully.")
          :ok

        {:error, :create_stripe_customer,
         %Stripe.Error{
           extra: %{card_code: :card_declined, raw_error: %{"decline_code" => decline_code}}
         } = failed_value, _changes_so_far} ->
          Logger.info("Card declined because #{decline_code}")
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card was declined. Please try another card."}

          add_error_to_form_changeset(
            changeset,
            "Your card was declined. Please try another card."
          )

        {:error, :create_stripe_customer,
         %Stripe.Error{extra: %{card_code: :expired_card}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card has expired. Please try another card."}

          add_error_to_form_changeset(
            changeset,
            "Your card has expired. Please try another card."
          )

        {:error, :create_stripe_customer,
         %Stripe.Error{extra: %{card_code: :incorrect_cvc}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card CVC is wrong. Please try again."}
          add_error_to_form_changeset(changeset, "Your card CVC is wrong. Please try again.")

        {:error, :create_stripe_customer,
         %Stripe.Error{extra: %{card_code: :processing_error}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Could not process your subscription at this time. Please try again."}

          add_error_to_form_changeset(
            changeset,
            "Could not process your subscription at this time. Please try again."
          )

        {:error, :create_stripe_customer, failed_value, _changes_so_far} ->
          Logger.info("Error during create_stripe_customer response: #{inspect(failed_value)}")
          {:error, "Could not process your subscription at this time. Please try again."}

          add_error_to_form_changeset(
            changeset,
            "Could not process your subscription at this time. Please try again."
          )

        {:error, :create_stripe_subscription,
         %Stripe.Error{
           extra: %{card_code: :card_declined, raw_error: %{"decline_code" => decline_code}}
         } = failed_value, %{create_stripe_customer: stripe_customer}} ->
          Logger.info("Card declined because #{decline_code}")
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card was declined. Please try another card."}

          destroy_stripe_customer(stripe_customer)

          add_error_to_form_changeset(
            changeset,
            "Your card was declined. Please try another card."
          )

        {:error, :create_stripe_subscription, failed_value,
         %{create_stripe_customer: stripe_customer}} ->
          Logger.info(
            "Error during create_stripe_subscription response: #{inspect(failed_value)}"
          )

          case destroy_stripe_customer(stripe_customer) do
            {:error, response} ->
              # Try again just in case
              destroy_stripe_customer(stripe_customer)
          end

          {:error, "Could not process your subscription at this time. Please try again."}

          add_error_to_form_changeset(
            changeset,
            "Could not process your subscription at this time. Please try again."
          )

        {:error, :check_initial_payment_succeeded, failed_value,
         %{
           create_stripe_customer: stripe_customer,
           create_stripe_subscription: stripe_subscription
         }} ->
          Logger.info(
            "Error during check_initial_payment_succeeded response: #{inspect(failed_value)}"
          )

          {:error, "Could not process your subscription at this time. Please try again."}

          destroy_stripe_subscription(stripe_subscription)
          destroy_stripe_customer(stripe_customer)

          add_error_to_form_changeset(
            changeset,
            "Could not process your subscription at this time. Please try again."
          )

        {:error, :update_company_with_stripe_data, changeset,
         %{
           create_stripe_customer: stripe_customer,
           create_stripe_subscription: stripe_subscription
         }} ->
          destroy_stripe_subscription(stripe_subscription)
          destroy_stripe_customer(stripe_customer)
          {:error, "Could not process your subscription at this time. Please try again."}

          {:error,
           add_error_to_form_changeset(
             changeset,
             "Could not process your subscription at this time. Please try again."
           )}
      end
    else
      {:error, changeset}
    end
  end

  @doc """
  This is the metered plan we need cancel right away by deleting the subscription.
  https://stripe.com/docs/billing/subscriptions/canceling-pausing
  """
  def cancel_subscription(company, "plan_Eyp0J9dUxi2tWW") do
    {:ok, success_response} = Stripe.Subscription.delete(company.stripe_subscription_id)
    Logger.info(inspect(success_response))

    {:ok, _updated_company} =
      update_company(company, %{stripe_payment_plan_id: nil, stripe_subscription_id: nil})

    :ok
  end

  def cancel_subscription(company, stripe_payment_plan_id) do
    {:ok, success_response} =
      Stripe.Subscription.update(company.stripe_subscription_id, %{cancel_at_period_end: true})

    Logger.info(inspect(success_response))

    {:ok, _updated_company} =
      update_company(company, %{stripe_payment_plan_id: nil, stripe_subscription_id: nil})

    :ok
  end

  @doc """
  https://stripe.com/docs/billing/subscriptions/upgrading-downgrading
  """
  def update_subscription(company, new_stripe_payment_plan_id) do
    {:ok, existing_subscription} = Stripe.Subscription.retrieve(company.stripe_subscription_id)

    [subscription_item | _] = existing_subscription.items.data

    if existing_subscription.plan.usage_type == "metered" do
      :ok = cancel_subscription(company, existing_subscription.plan.id)

      {:ok, stripe_customer} = Stripe.Customer.retrieve(company.stripe_customer_id)

      {:ok, new_subscription} =
        create_stripe_subscription(stripe_customer, new_stripe_payment_plan_id,
          enable_incomplete_payments: true
        )

      Company.changeset(company, %{
        stripe_payment_plan_id: new_stripe_payment_plan_id,
        stripe_subscription_id: new_subscription.id
      })
      |> Repo.update()
    else
      {:ok, subscription} =
        Stripe.Subscription.update(
          company.stripe_subscription_id,
          %{
            cancel_at_period_end: false,
            items: [
              %{
                id: subscription_item.id,
                plan: new_stripe_payment_plan_id
              }
            ]
          }
        )

      Company.changeset(company, %{
        stripe_payment_plan_id: new_stripe_payment_plan_id,
        stripe_subscription_id: subscription.id
      })
      |> Repo.update()
    end
  end

  defp create_stripe_customer(user, company, stripe_credit_card_token) do
    %{
      description: "#{company.name} - Contact: #{user.full_name} - #{company.contact_email}",
      name: "#{company.name} - #{user.full_name}",
      email: company.contact_email,
      source: stripe_credit_card_token,
      metadata: %{
        company_id: company.id,
        user_id: user.id
      }
    }
    |> Stripe.Customer.create()
  end

  defp create_stripe_subscription(stripe_customer, stripe_payment_plan_id, opts \\ []) do
    %{
      customer: stripe_customer.id,
      billing: "charge_automatically",
      items: [
        %{
          plan: stripe_payment_plan_id
        }
      ],
      expand: ["latest_invoice.payment_intent"]
    }
    |> Stripe.Subscription.create(opts)
  end

  def create_payment_plan_record(
        company,
        stripe_customer,
        stripe_subscription,
        stripe_payment_plan_id
      ) do
    attrs = %{
      company_id: company.id,
      stripe_customer_id: stripe_customer.id,
      stripe_payment_plan_id: stripe_payment_plan_id,
      stripe_subscription_id: stripe_subscription.id,
      stripe_subscription_data: %{}
    }

    %PaymentPlan{}
    |> PaymentPlan.changeset(attrs)
    |> Repo.insert!()
  end

  defp destroy_stripe_customer(stripe_customer) do
    {:ok, success_response} = Stripe.Customer.delete(stripe_customer.id)
  end

  defp destroy_stripe_subscription(stripe_subscription) do
    {:ok, success_response} = Stripe.Subscription.delete(stripe_subscription.id)
  end

  def add_error_to_form_changeset(changeset, error_message) do
    # add_error_to_form_changeset(changeset, "Your card was declined. Please try another card.")
    {:error,
     %{changeset | action: :subscription_payment}
     |> Ecto.Changeset.add_error(:credit_or_debit_card, error_message)}
  end

  def upcoming_invoice(company) do
    {:ok, upcoming_invoice} =
      Stripe.Invoice.upcoming(%{
        subscription: company.stripe_subscription_id,
        customer: company.stripe_customer_id
      })

    upcoming_invoice
  end

  def handle_invoice_payment_fail(stripe_event) do
    %Stripe.Event{
      data: %{
        object: %Stripe.Invoice{
          attempted: true,
          customer: stripe_customer_id,
          paid: false
        }
      }
    } = stripe_event

    case Repo.get_by(Company, stripe_customer_id: stripe_customer_id) do
      nil ->
        nil

      company ->
        cancel_subscription(company, company.stripe_payment_plan_id)
    end
  end

  def report_usage(company, "plan_Eyp0J9dUxi2tWW") do
    %Stripe.Subscription{
      items: %Stripe.List{
        data: [
          %Stripe.SubscriptionItem{
            id: subscription_item_id,
            plan: %Stripe.Plan{
              id: "plan_Eyp0J9dUxi2tWW"
            }
          }
        ]
      }
    } = get_current_subscription(company.stripe_subscription_id)

    params = %{
      quantity: 1,
      action: "increment",
      timestamp: DateTime.utc_now() |> DateTime.to_unix()
    }

    {:ok, record} = Stripe.SubscriptionItem.Usage.create(subscription_item_id, params)
  end

  def report_usage(company, _any_other_plan) do
  end
end
