defmodule Lucuma.Billing.PaymentPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payment_plans" do
    field :stripe_customer_id, :string
    field :stripe_payment_plan_id, :string
    field :stripe_subscription_id, :string
    field :stripe_subscription_data, :map

    belongs_to :company, Lucuma.Accounts.Company

    timestamps()
  end

  @doc false
  def changeset(payment_plan, attrs) do
    payment_plan
    |> cast(attrs, [
      :company_id,
      :stripe_customer_id,
      :stripe_payment_plan_id,
      :stripe_subscription_id,
      :stripe_subscription_data
    ])
    |> validate_required([
      :company_id,
      :stripe_customer_id,
      :stripe_payment_plan_id,
      :stripe_subscription_id,
      :stripe_subscription_data
    ])
    |> foreign_key_constraint(:company_id)
  end
end
