defmodule Lucuma.Waitlists.StandBy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stand_bys" do
    field :contact_phone_number, :string
    field :estimated_wait_time, :integer
    field :name, :string
    field :notes, :string
    field :party_size, :integer
    field :notified_at, :utc_datetime
    field :attended_at, :utc_datetime
    field :no_show_at, :utc_datetime
    field :cancelled_at, :utc_datetime
    field :cancellation_uuid, :string

    belongs_to :waitlist, Lucuma.Waitlists.Waitlist
    has_many :sms_notifications, Lucuma.Notifications.SmsNotification, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(standby, attrs) do
    standby
    |> cast(attrs, [
      :name,
      :contact_phone_number,
      :party_size,
      :estimated_wait_time,
      :notes,
      :waitlist_id,
      :notified_at,
      :attended_at,
      :no_show_at,
      :cancelled_at
    ])
    |> validate_required([
      :name,
      :contact_phone_number,
      :party_size,
      :estimated_wait_time,
      :waitlist_id
    ])
    |> validate_phone_number(:contact_phone_number)
    |> generate_cancellation_uuid()
  end

  def validate_phone_number(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, phone_number ->
      case ExPhoneNumber.parse(phone_number, "") do
        {:error, reason} ->
          [{field, options[:message] || "invalid phone number."}]

        {:ok, number} ->
          case ExPhoneNumber.is_valid_number?(number) do
            true -> []
            false -> [{field, options[:message] || "invalid phone number."}]
          end
      end
    end)
  end

  def generate_cancellation_uuid(changeset) do
    case get_field(changeset, :cancellation_uuid) do
      nil -> put_change(changeset, :cancellation_uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
