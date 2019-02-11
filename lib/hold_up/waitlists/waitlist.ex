defmodule HoldUp.Waitlists.Waitlist do
  use Ecto.Schema
  import Ecto.Changeset


  schema "waitlists" do
    field :name, :string
    field :business_id, :id
    field :notification_sms_body, :string

    timestamps()

    has_many :stand_bys, HoldUp.Waitlists.StandBy
  end

  @doc false
  def changeset(waitlist, attrs) do
    waitlist
    |> cast(attrs, [:name, :notification_sms_body])
    |> validate_required([:name])
  end
end