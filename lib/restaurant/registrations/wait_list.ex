defmodule Restaurant.Registrations.WaitList do
  use Ecto.Schema
  import Ecto.Changeset


  schema "wait_lists" do
    field :name, :string
    field :restaurant_id, :id, null: false

    timestamps()
  end

  @doc false
  def changeset(wait_list, attrs) do
    wait_list
    |> cast(attrs, [:name, :restaurant_id])
    |> validate_required([:name, :restaurant_id])
  end
end
