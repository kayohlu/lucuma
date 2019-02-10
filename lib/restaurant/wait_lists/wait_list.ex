defmodule HoldUp.WaitLists.WaitList do
  use Ecto.Schema
  import Ecto.Changeset


  schema "wait_lists" do
    field :name, :string
    field :hold_up_id, :id
    field :notification_sms_body, :string

    timestamps()

    has_many :stand_bys, HoldUp.WaitLists.StandBy
  end

  @doc false
  def changeset(wait_list, attrs) do
    wait_list
    |> cast(attrs, [:name, :notification_sms_body])
    |> validate_required([:name])
  end
end
