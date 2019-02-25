defmodule HoldUp.Notifications.Notifier do
  alias HoldUp.Notifications
  alias HoldUpWeb.Router.Helpers
  alias HoldUpWeb.Waitlists
  alias HoldUp.Repo
  alias HoldUp.Notifications.SmsNotification

  import Ecto.Query

  @doc """
  The lock line below allows us to lock those records so another machine running the same process
  cannot query for the same rows in the db resulting in the same sms_notfications being processed more than once.
  The "FOR UPDATE SKIP LOCKED" allows us to "skip" the lock when updating said locked records.
  """
  def enqueue_notifications do
    {:ok, results} = Repo.transaction(fn ->
      for_delivery_ids =
        Repo.all(
          from sms in SmsNotification,
            where: sms.status == "for_delivery",
            lock: "FOR UPDATE SKIP LOCKED",
            select: sms.id
        )

      {_count, sms_notifications} =
        Repo.update_all(
          (from sms in SmsNotification,
            where: sms.id in ^for_delivery_ids),
            [set: [status: "queued_for_delivery"]],
            returning: true # returns all fields
        )
      sms_notifications
    end)

    results
  end

  def send_notification(%SmsNotification{} = sms_notification) do
    send_notification(Mix.env(), sms_notification)
  end

  defp send_notification(:prod, sms_notification) do
    [twilio_number_data] = ExTwilio.IncomingPhoneNumber.all()

    ExTwilio.Message.create(
      to: sms_notification.recipient_phone_number,
      from: twilio_number_data.phone_number,
      body: sms_notification.message_content,
      status_callback: Helpers.sms_status_url(HoldUpWeb.Endpoint, :create, sms_notification.id)
    )
    |> handle_api_response(sms_notification)
  end

  defp send_notification(_mix_env, sms_notification) do
    ExTwilio.Message.create(
      to: sms_notification.recipient_phone_number,
      from: System.get_env("TWILIO_DEV_FROM_NUMBER"),
      body: sms_notification.message_content
    )
    |> handle_api_response(sms_notification)
  end

  defp handle_api_response(:ok = result, sms_notification) do
    Notifications.update_sms_notification(sms_notification, %{status: "delivering"})
  end

  defp handle_api_response({:ok, response} = result, sms_notification) do
    Notifications.update_sms_notification(sms_notification, %{status: "delivering"})
  end

  defp handle_api_response({:error, response, response_code} = result, sms_notification) do
    %{"code" => error_code} = response
    case error_code do
      21211 -> # phone number is invalid.
        Notifications.update_sms_notification(sms_notification, %{status: "cannot_deliver"})
      21612 -> # twillio can't route to this number
        Notifications.update_sms_notification(sms_notification, %{status: "cannot_deliver"})
      21614 -> # not a mobile number
        Notifications.update_sms_notification(sms_notification, %{status: "cannot_deliver"})
      21408 -> # no geo permissions
        Notifications.update_sms_notification(sms_notification, %{status: "for_delivery"})
      21610 -> # blacklisted number
        Notifications.update_sms_notification(sms_notification, %{status: "cannot_deliver"})
      _ ->
        Notifications.update_sms_notification(sms_notification, %{status: "for_delivery"})
    end
  end
end
