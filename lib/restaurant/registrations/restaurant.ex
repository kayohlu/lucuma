defmodule Restaurant.Registrations.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset


  schema "restaurants" do
    field :name, :string
    field :company_id, :id, null: false

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :company_id])
    |> validate_required([:name, :company_id])
  end
end