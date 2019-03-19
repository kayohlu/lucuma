defmodule HoldUp.Notifications.Notifier do
  alias HoldUpWeb.Router.Helpers
  alias HoldUp.Notifications
  alias HoldUp.Notifications.SmsNotification

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
    Notifications.update_sms_notification!(sms_notification, %{status: "delivering"})
  end

  defp handle_api_response({:ok, response} = result, sms_notification) do
    Notifications.update_sms_notification!(sms_notification, %{status: "delivering"})
  end

  defp handle_api_response({:error, response, response_code} = result, sms_notification) do
    %{"code" => error_code} = response

    case error_code do
      # phone number is invalid.
      21211 ->
        Notifications.update_sms_notification!(sms_notification, %{status: "cannot_deliver"})

      # twillio can't route to this number
      21612 ->
        Notifications.update_sms_notification!(sms_notification, %{status: "cannot_deliver"})

      # not a mobile number
      21614 ->
        Notifications.update_sms_notification!(sms_notification, %{status: "cannot_deliver"})

      # no geo permissions
      21408 ->
        Notifications.update_sms_notification!(sms_notification, %{status: "for_delivery"})

      # blacklisted number
      21610 ->
        Notifications.update_sms_notification!(sms_notification, %{status: "cannot_deliver"})

      _ ->
        Notifications.update_sms_notification!(sms_notification, %{status: "for_delivery"})
    end
  end
end
