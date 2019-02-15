defmodule HoldUp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :confirmation_sent_at, :utc_datetime
    field :confirmation_token, :string
    field :confirmed_at, :utc_datetime
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :reset_password_token, :string

    belongs_to :company, HoldUp.Accounts.Company

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :full_name, :password_hash, :reset_password_token, :confirmation_token, :confirmed_at, :confirmation_sent_at, :company_id])
    |> validate_required([:email, :full_name, :password_hash, :company_id])
  end
end