defmodule HoldUp.Notifications do
  import Ecto.Query, warn: false

  alias HoldUp.Repo
  alias HoldUp.Notifications.SmsNotification

  def get_sms_notification!(id), do: Repo.get!(SmsNotification, id)

  def create_sms_notification(attrs \\ %{}) do
    %SmsNotification{}
    |> SmsNotification.changeset(attrs)
    |> Repo.insert()
  end

  def update_sms_notification(%SmsNotification{} = sms_notification, attrs) do
    sms_notification
    |> SmsNotification.changeset(attrs)
    |> Repo.update()
  end
end