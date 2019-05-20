defmodule HoldUp.BillingTest do
  use HoldUp.DataCase

  alias HoldUp.Billing

  describe "payment_plans" do
    alias HoldUp.Billing.PaymentPlan

    @valid_attrs %{active: true, stripe_id: "some stripe_id"}
    @update_attrs %{active: false, stripe_id: "some updated stripe_id"}
    @invalid_attrs %{active: nil, stripe_id: nil}

    def payment_plan_fixture(attrs \\ %{}) do
      {:ok, payment_plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Billing.create_payment_plan()

      payment_plan
    end

    test "list_payment_plans/0 returns all payment_plans" do
      payment_plan = payment_plan_fixture()
      assert Billing.list_payment_plans() == [payment_plan]
    end

    test "get_payment_plan!/1 returns the payment_plan with given id" do
      payment_plan = payment_plan_fixture()
      assert Billing.get_payment_plan!(payment_plan.id) == payment_plan
    end

    test "create_payment_plan/1 with valid data creates a payment_plan" do
      assert {:ok, %PaymentPlan{} = payment_plan} = Billing.create_payment_plan(@valid_attrs)
      assert payment_plan.active == true
      assert payment_plan.stripe_id == "some stripe_id"
    end

    test "create_payment_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_payment_plan(@invalid_attrs)
    end

    test "update_payment_plan/2 with valid data updates the payment_plan" do
      payment_plan = payment_plan_fixture()
      assert {:ok, %PaymentPlan{} = payment_plan} = Billing.update_payment_plan(payment_plan, @update_attrs)
      assert payment_plan.active == false
      assert payment_plan.stripe_id == "some updated stripe_id"
    end

    test "update_payment_plan/2 with invalid data returns error changeset" do
      payment_plan = payment_plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_payment_plan(payment_plan, @invalid_attrs)
      assert payment_plan == Billing.get_payment_plan!(payment_plan.id)
    end

    test "delete_payment_plan/1 deletes the payment_plan" do
      payment_plan = payment_plan_fixture()
      assert {:ok, %PaymentPlan{}} = Billing.delete_payment_plan(payment_plan)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_payment_plan!(payment_plan.id) end
    end

    test "change_payment_plan/1 returns a payment_plan changeset" do
      payment_plan = payment_plan_fixture()
      assert %Ecto.Changeset{} = Billing.change_payment_plan(payment_plan)
    end
  end
end
