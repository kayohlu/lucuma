defmodule HoldUp.Billing do
  @moduledoc """
  The Billing context.
  """
  require Logger
  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.Billing.Company
  alias HoldUp.Billing.SubscriptionForm

  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  def plans do
    {:ok, %Stripe.List{data: [%Stripe.Product{id: product_id}]}} = Stripe.Product.list
    Stripe.Plan.list(%{product: product_id})
  end

  def create_subscription(user, company, %{"id" => stripe_payment_plan_id, "stripeToken" => stripe_credit_card_token} = form_params) do
    # changeset = SubscriptionForm.changeset(%SubscriptionForm{}, form_params)

    # if changeset.valid? do
      # subscription_form = Ecto.Changeset.apply_changes(changeset)

      multi_result =
      Ecto.Multi.new
      |> Ecto.Multi.run(:create_stripe_customer, fn repo, previous_steps ->
        create_stripe_customer(user, company, stripe_credit_card_token)
      end)
      |> Ecto.Multi.run(:create_stripe_subscription, fn _repo, %{create_stripe_customer: stripe_customer} ->
        create_stripe_subscription(stripe_customer, stripe_payment_plan_id)
      end)
      |> Ecto.Multi.update(:update_company_with_stripe_data, fn %{create_stripe_customer: stripe_customer} ->
        Company.changeset(%{id: company.id}, %{stripe_customer_id: stripe_customer.id, stripe_payment_plan_id: stripe_payment_plan_id})
      end)
      |> Repo.transaction

      case multi_result do
        {:ok, steps} -> :ok
        {:error, :create_stripe_customer, %Stripe.Error{extra: %{card_code: :card_declined, raw_error: %{"decline_code" => decline_code}}} = failed_value, _changes_so_far} ->
          Logger.info("Card declined because #{decline_code}")
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card was declined. Please try another card."}
        {:error, :create_stripe_customer, %Stripe.Error{extra: %{card_code: :expired_card}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card has expired. Please try another card."}
        {:error, :create_stripe_customer, %Stripe.Error{extra: %{card_code: :incorrect_cvc}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card CVC is wrong. Please try again."}
        {:error, :create_stripe_customer, %Stripe.Error{extra: %{card_code: :processing_error}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Could not process your subscription at this time. Please try again."}
        {:error, :create_stripe_customer, %Stripe.Error{extra: %{card_code: :card_declined, raw_error: %{"decline_code" => decline_code}}} = failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Your card was declined. Please try again."}
        {:error, :create_stripe_customer, failed_value, _changes_so_far} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          {:error, "Could not process your subscription at this time. Please try again."}
        {:error, :create_stripe_subscription, failed_value, %{create_stripe_customer: stripe_customer}} ->
          Logger.info("Card decline response: #{inspect(failed_value)}")
          case destroy_stripe_customer(stripe_customer) do
            {:error, response} ->
              # Try again just in case
              destroy_stripe_customer(stripe_customer)
          end
          {:error, "Could not process your subscription at this time. Please try again."}
        {:error, :update_company_with_stripe_data, {:error, changeset}, %{create_stripe_customer: stripe_customer, create_stripe_subscription: stripe_subscription}} ->
          destroy_stripe_customer(stripe_customer)
          destroy_stripe_subscription(stripe_subscription)
          {:error, "Could not process your subscription at this time. Please try again."}
      end
    # end
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
    |> Stripe.Customer.create
  end

  defp create_stripe_subscription(stripe_customer, stripe_playment_plan_id) do
    %{
      customer: stripe_customer.id,
      billing: "charge_automatically",
      items: [
        %{
          plan: stripe_playment_plan_id
        }
      ],
      expand: ["latest_invoice.payment_intent"]
    }
    |> Stripe.Subscription.create
  end

  defp destroy_stripe_customer(stripe_customer) do
    Stripe.Customer.delete(stripe_customer.id)
  end

  defp destroy_stripe_subscription(stripe_subscription) do
    Stripe.Subscription.delete(stripe_subscription.id)
  end

  def add_error_to_form_changeset(changeset, error_message) do
    # add_error_to_form_changeset(changeset, "Your card was declined. Please try another card.")
  end
end