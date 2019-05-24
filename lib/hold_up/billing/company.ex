defmodule HoldUp.Billing.Company do
  use Ecto.Schema
  import Ecto.Changeset

  schema "companies" do
    field :stripe_customer_id, :string
    field :stripe_payment_plan_id, :string
    field :stripe_subscription_id, :string

    has_many :users, HoldUp.Accounts.User
    has_many :businesses, HoldUp.Accounts.Business
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:stripe_customer_id, :stripe_payment_plan_id, :stripe_subscription_id])
    |> validate_required([:stripe_customer_id, :stripe_payment_plan_id, :stripe_subscription_id])
  end
end
