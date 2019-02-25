defmodule HoldUp.Waitlists.SmsSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sms_settings" do
    field :message_content, :string
    field :waitlist_id, :id

    timestamps()
  end

  @doc false
  def changeset(sms_setting, attrs) do
    sms_setting
    |> cast(attrs, [:message_content, :waitlist_id])
    |> validate_required([:message_content, :waitlist_id])
  end
end
