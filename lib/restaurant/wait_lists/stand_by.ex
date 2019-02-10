defmodule HoldUp.WaitLists.StandBy do
  use Ecto.Schema
  import Ecto.Changeset


  schema "stand_bys" do
    field :contact_phone_number, :string
    field :estimated_wait_time, :integer
    field :name, :string
    field :notes, :string
    field :party_size, :integer
    field :wait_list_id, :integer
    field :notified_at, :utc_datetime
    field :attended_at, :utc_datetime
    field :no_show_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(standby, attrs) do
    standby
    |> cast(attrs, [:name, :contact_phone_number, :party_size, :estimated_wait_time, :notes, :wait_list_id, :notified_at, :attended_at, :no_show_at])
    |> validate_required([:name, :contact_phone_number, :party_size, :estimated_wait_time, :notes, :wait_list_id])
    |> validate_phone_number(:contact_phone_number)
  end

  def validate_phone_number(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, phone_number ->
      {:ok, number} = ExPhoneNumber.parse(phone_number, "")

      case ExPhoneNumber.is_valid_number?(number) do
        true -> []
        false -> [{field, options[:message] || "invalid phone number."}]
      end
    end)
  end
end