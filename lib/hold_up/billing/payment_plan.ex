defmodule HoldUp.Billing.PaymentPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payment_plans" do
    field :active, :boolean, default: false
    field :stripe_id, :string
    field :company_id, :id

    timestamps()
  end

  @doc false
  def changeset(payment_plan, attrs) do
    payment_plan
    |> cast(attrs, [:stripe_id, :active])
    |> validate_required([:stripe_id, :active])
  end
end
