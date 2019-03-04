defmodule HoldUp.Waitlists.ConfirmationSmsSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "confirmation_sms_settings" do
    field :enabled, :boolean
    field :message_content, :string
    field :waitlist_id, :id

    timestamps()
  end

  @doc false
  def changeset(sms_setting, attrs) do
    sms_setting
    |> cast(attrs, [:enabled, :message_content, :waitlist_id])
    |> validate_required([:enabled, :message_content, :waitlist_id])
  end
end
