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

    case result do
      {:ok, sms_notification} ->
        {:ok, sms_notification}
        send_sms_notification

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def send_sms_notification do
    Lucuma.Notifications.V4.NotificationBroadcaster.async_notify()

    {:ok, :queued}
  end

  @doc """
  The lock line below allows us to lock those records so another machine running the same process
  cannot query for the same rows in the db resulting in the same sms_notfications being processed more than once.
  The "FOR UPDATE SKIP LOCKED" allows us to "skip" the lock when updating said locked records.
  """
  def notifications_for_dispatch(limit \\ nil) do
    {:ok, results} =
      Repo.transaction(fn ->
        for_delivery_ids =
          Repo.all(
            from sms in SmsNotification,
              where: sms.status == "for_delivery",
              lock: "FOR UPDATE SKIP LOCKED",
              select: sms.id,
              limit: ^limit
          )

        {_count, sms_notifications} =
          Repo.update_all(
            from(sms in SmsNotification,
              where: sms.id in ^for_delivery_ids,
              select: sms
            ),
            [set: [status: "queued_for_delivery"]],
            # returns all fields
            returning: true
          )

        sms_notifications
      end)

    results || []
  end
end
