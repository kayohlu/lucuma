defmodule Lucuma.Notifications do
  import Ecto.Query, warn: false

  alias Lucuma.Repo
  alias Lucuma.Notifications.SmsNotification

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

  def update_sms_notification!(%SmsNotification{} = sms_notification, attrs) do
    sms_notification
    |> SmsNotification.changeset(attrs)
    |> Repo.update!()
  end

  def send_sms_notification(recipient_phone_number, message_content, stand_by_id) do
    result =
      create_sms_notification(%{
        stand_by_id: stand_by_id,
        message_content: message_content,
        recipient_phone_number: recipient_phone_number
      })

    if {:ok, sms_notification} = result do
      Lucuma.Notifications.NotificationProducer.send_sms_async()
    end

    result
  end
end
