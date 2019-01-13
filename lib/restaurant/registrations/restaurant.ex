defmodule Restaurant.Registrations.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset


  schema "restaurants" do
    field :name, :string
    field :company_id, :id

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end