defmodule HoldUp.BillingTest do
  use HoldUp.DataCase, async: false

  import HoldUp.Factory

  alias HoldUp.Billing
  alias HoldUp.Accounts
  alias HoldUp.Accounts.Company

  setup_all do
    :ok
  end

  describe "#create_subscription/3" do
    test "returns the changeset when the subscription form is invalid", state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => nil}
        )

      assert {:error, %Ecto.Changeset{valid?: false} = changeset} = result
    end

    test "creates a stripe subscription, customer, and updates the company record with that info when the subscription form is valid",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_visa"}
        )

      assert :ok = result
      updated_company = Repo.get(Company, user.company_id)
      refute updated_company.stripe_subscription_id == nil
      refute updated_company.stripe_payment_plan_id == nil
      refute updated_company.stripe_customer_id == nil
    end

    test "returns the changeset with the correct error message when the customer creation with Stripe failed because they declined the card",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_chargeDeclined"}
        )

      assert {:error,
              %Ecto.Changeset{
                valid?: false,
                errors: [
                  credit_or_debit_card: {"Your card was declined. Please try another card.", []}
                ]
              } = changeset} = result
    end

    test "returns the changeset with the correct error message when the customer creation with Stripe failed because the card has expired",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_chargeDeclinedExpiredCard"}
        )

      assert {:error,
              %Ecto.Changeset{
                valid?: false,
                errors: [
                  credit_or_debit_card: {"Your card has expired. Please try another card.", []}
                ]
              } = changeset} = result
    end

    test "returns the changeset with the correct error message when the customer creation with Stripe failed because the cvc entered was wrong",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_chargeDeclinedIncorrectCvc"}
        )

      assert {:error,
              %Ecto.Changeset{
                valid?: false,
                errors: [credit_or_debit_card: {"Your card CVC is wrong. Please try again.", []}]
              } = changeset} = result
    end

    test "returns the changeset with the correct error message when the customer creation with Stripe failed because of a processing error",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_chargeDeclinedProcessingError"}
        )

      assert {:error,
              %Ecto.Changeset{
                valid?: false,
                errors: [
                  credit_or_debit_card:
                    {"Could not process your subscription at this time. Please try again.", []}
                ]
              } = changeset} = result
    end

    test "returns the changeset with the correct error message when the customer creation with Stripe failed because of some error we have not accounted for",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_avsFail"}
        )

      assert {:error,
              %Ecto.Changeset{
                valid?: false,
                errors: [
                  credit_or_debit_card:
                    {"Could not process your subscription at this time. Please try again.", []}
                ]
              } = changeset} = result
    end

    # test "returns the changeset with the correct error message when the subscription creation with Stripe failed because they declined the card", state do
    # end

    # test "returns the changeset with the correct error message when the subscription creation with Stripe failed because of some error we have not accounted for", state do
    # end

    # test "returns the changeset with the correct error message when the subscription creation with Stripe failed because of some error we have not accounted for", state do
    # end

    # test "destroys the stripe customer and subscription, returns the changeset with the correct error message when updating the company record with stripe data fails", state do
    # end
  end

  describe "#cancel_subscription/2" do
    test "clears the stripe data from the company record, cancels the subscription immediately with stripe when its the metered subscription",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_visa"}
        )

      assert :ok = result

      company_with_stripe_data = Repo.get(Company, user.company_id)

      assert :ok = Billing.cancel_subscription(company_with_stripe_data, "plan_Eyp0J9dUxi2tWW")

      company_without_stripe_data = Repo.get(Company, user.company_id)

      assert {:ok, %Stripe.Subscription{status: "canceled"}} =
               Stripe.Subscription.retrieve(company_with_stripe_data.stripe_subscription_id)

      assert company_without_stripe_data.stripe_subscription_id == nil
      assert company_without_stripe_data.stripe_payment_plan_id == nil
    end

    test "clears the stripe data from the company record, cancels updates the subscription to cancel at the end of the period with stripe when its a licensed subscription",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyox8DhvcBMAaS", "stripeToken" => "tok_visa"}
        )

      assert :ok = result

      company_with_stripe_data = Repo.get(Company, user.company_id)

      assert :ok = Billing.cancel_subscription(company_with_stripe_data, "plan_Eyox8DhvcBMAaS")

      company_without_stripe_data = Repo.get(Company, user.company_id)

      assert {:ok, %Stripe.Subscription{status: "active", cancel_at_period_end: true}} =
               Stripe.Subscription.retrieve(company_with_stripe_data.stripe_subscription_id)

      assert company_without_stripe_data.stripe_subscription_id == nil
      assert company_without_stripe_data.stripe_payment_plan_id == nil
    end
  end

  # # This is really upgrade/change current subscription
  describe "#update_subscription/2" do
    test "cancels the subscription, creates a new one, and updates the company record with the new subscription id and payment plan id when its the metered subscription",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_visa"}
        )

      assert :ok = result

      company_with_original_stripe_data = Repo.get(Company, user.company_id)

      # plan_Eyox8DhvcBMAaS == licensed
      assert {:ok, company_with_new_stripe_data} =
               Billing.update_subscription(
                 company_with_original_stripe_data,
                 "plan_Eyox8DhvcBMAaS"
               )

      assert {:ok, %Stripe.Subscription{status: "canceled"}} =
               Stripe.Subscription.retrieve(
                 company_with_original_stripe_data.stripe_subscription_id
               )

      refute company_with_new_stripe_data.stripe_subscription_id == nil
      refute company_with_new_stripe_data.stripe_payment_plan_id == nil

      refute company_with_new_stripe_data.stripe_subscription_id ==
               company_with_original_stripe_data.stripe_subscription_id

      refute company_with_new_stripe_data.stripe_payment_plan_id ==
               company_with_original_stripe_data.stripe_payment_plan_id
    end

    test "changes the current subscriptions payment plan id  when its a licensed subscription",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyox8DhvcBMAaS", "stripeToken" => "tok_visa"}
        )

      assert :ok = result

      company_with_original_stripe_data = Repo.get(Company, user.company_id)

      # plan_F7YntQ0ELRD33U == licensed
      assert {:ok, company_with_new_stripe_data} =
               Billing.update_subscription(
                 company_with_original_stripe_data,
                 "plan_F7YntQ0ELRD33U"
               )

      assert {:ok,
              %Stripe.Subscription{
                status: "active",
                cancel_at_period_end: false,
                items: %Stripe.List{
                  data: [%Stripe.SubscriptionItem{plan: %Stripe.Plan{id: "plan_F7YntQ0ELRD33U"}}]
                }
              }} =
               Stripe.Subscription.retrieve(
                 company_with_original_stripe_data.stripe_subscription_id
               )

      refute company_with_new_stripe_data.stripe_subscription_id == nil
      refute company_with_new_stripe_data.stripe_payment_plan_id == nil

      refute company_with_new_stripe_data.stripe_payment_plan_id ==
               company_with_original_stripe_data.stripe_payment_plan_id
    end
  end

  describe "#handle_invoice_payment_fail/2" do
    test "cancels the subscription and removes the relevant info from the company record",
         state do
      company = insert(:company)
      user = insert(:user, company: company, email: "a@a.com")

      result =
        Billing.create_subscription(
          user,
          company,
          %{"id" => "plan_Eyp0J9dUxi2tWW", "stripeToken" => "tok_visa"}
        )

      assert :ok = result

      company_with_stripe_data = Repo.get(Company, user.company_id)

      stripe_event = %Stripe.Event{
        data: %{
          object: %Stripe.Invoice{
            attempted: true,
            customer: company_with_stripe_data.stripe_customer_id,
            paid: false
          }
        }
      }

      Billing.handle_invoice_payment_fail(stripe_event)

      company_without_stripe_data = Repo.get(Company, user.company_id)

      assert company_without_stripe_data.stripe_subscription_id == nil
      assert company_without_stripe_data.stripe_payment_plan_id == nil
    end
  end
end
