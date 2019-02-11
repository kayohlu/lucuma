defmodule HoldUp.WaitLists.SmsSetting do
  use Ecto.Schema
  import Ecto.Changeset


  schema "sms_settings" do
    field :message_content, :string
    field :wait_list_id, :id

    timestamps()
  end

  @doc false
  def changeset(sms_setting, attrs) do
    sms_setting
    |> cast(attrs, [:message_content])
    |> validate_required([:message_content])
  end
end
