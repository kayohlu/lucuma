defmodule HoldUp.Registrations.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :company_id, :id, null: false

    timestamps()

  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :full_name, :password_hash, :company_id])
    |> validate_required([:email, :full_name, :password_hash, :company_id])
  end
end