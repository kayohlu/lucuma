defmodule HoldUp.Registrations.WaitList do
  use Ecto.Schema
  import Ecto.Changeset


  schema "wait_lists" do
    field :name, :string
    field :business_id, :id, null: false

    timestamps()
  end

  @doc false
  def changeset(wait_list, attrs) do
    wait_list
    |> cast(attrs, [:name, :business_id])
    |> validate_required([:name, :business_id])
  end
end