defmodule Restaurant.WaitLists.StandBy do
  use Ecto.Schema
  import Ecto.Changeset


  schema "stand_bys" do
    field :contact_phone_number, :string
    field :estimated_wait_time, :integer
    field :name, :string
    field :notes, :string
    field :party_size, :integer
    field :wait_list_id, :integer

    timestamps()
  end

  @doc false
  def changeset(standby, attrs) do
    standby
    |> cast(attrs, [:name, :contact_phone_number, :party_size, :estimated_wait_time, :notes, :wait_list_id])
    |> validate_required([:name, :contact_phone_number, :party_size, :estimated_wait_time, :notes, :wait_list_id])
  end
end