defmodule Restaurant.Registrations.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:email, :full_name, :password_hash])
    |> validate_required([:email, :full_name, :password_hash])
  end
end