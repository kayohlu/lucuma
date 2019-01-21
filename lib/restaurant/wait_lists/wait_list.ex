defmodule Restaurant.WaitLists.WaitList do
  use Ecto.Schema
  import Ecto.Changeset


  schema "wait_lists" do
    field :name, :string
    field :restaurant_id, :id

    timestamps()

    has_many :stand_bys, Restaurant.WaitLists.StandBy
  end

  @doc false
  def changeset(wait_list, attrs) do
    wait_list
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
