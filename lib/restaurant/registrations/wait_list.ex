defmodule HoldUp.Registrations.WaitList do
  use Ecto.Schema
  import Ecto.Changeset


  schema "wait_lists" do
    field :name, :string
    field :hold_up_id, :id, null: false

    timestamps()
  end

  @doc false
  def changeset(wait_list, attrs) do
    wait_list
    |> cast(attrs, [:name, :hold_up_id])
    |> validate_required([:name, :hold_up_id])
  end
end