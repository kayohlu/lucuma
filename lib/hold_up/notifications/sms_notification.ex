defmodule HoldUp.Notifications.SmsNotification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sms_notifications" do
    field :message_content, :string
    field :recipient_phone_number, :string
    field :delivered_at, :utc_datetime
    field :failed_at, :utc_datetime

    belongs_to :stand_by, HoldUp.Waitlists.StandBy

    timestamps()
  end

  @doc false
  def changeset(sms_setting, attrs) do
    sms_setting
    |> cast(attrs, [:message_content, :recipient_phone_number, :delivered_at, :failed_at, :stand_by_id])
    |> validate_required([:message_content, :recipient_phone_number, :stand_by_id])
  end
end