defmodule HoldUp.Accounts.Company do
  use Ecto.Schema
  import Ecto.Changeset

  schema "companies" do
    field :contact_email, :string
    field :name, :string
    field :stripe_customer_id, :string
    field :stripe_payment_plan_id, :string
    field :stripe_subscription_id, :string

    timestamps()

    has_many :users, HoldUp.Accounts.User
    has_many :businesses, HoldUp.Accounts.Business
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :contact_email, :stripe_customer_id, :stripe_payment_plan_id, :stripe_subscription_id])
    |> validate_required([:name, :contact_email])
  end
end
