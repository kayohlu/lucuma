defmodule Lucuma.Notifications.Notifier do
  require Logger
  alias Lucuma.Repo
  alias LucumaWeb.Router.Helpers
  alias Lucuma.Notifications
  alias Lucuma.Notifications.SmsNotification

  def mark_notification_for_delivery(%SmsNotification{} = sms_notification) do
    sms_notification
    |> SmsNotification.changeset(%{status: "for_delivery"})
    |> Repo.update!()
  end

  def send_notification(%SmsNotification{} = sms_notification) do
    IO.inspect(sms_notification)
    send_notification(Mix.env(), sms_notification)
  end

  defp send_notification(:prod, sms_notification) do
    {:ok, response} = Mojito.request(
      method: :post,
      url: "https://api.mailjet.com/v4/sms-send",
      headers: [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{System.get_env("MAILJET_SMS_API_KEY")}"}
      ],
      body:  %{
        "Text" => sms_notification.message_content,
        "To" => sms_notification.recipient_phone_number,
        "From" => "Atunelogy"} |> Poison.encode!
    )
    IO.inspect response
  end

  defp send_notification(_mix_env, sms_notification) do
    {:ok, response} = Mojito.request(
      method: :post,
      url: "https://api.mailjet.com/v4/sms-send",
      headers: [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{System.get_env("MAILJET_SMS_API_KEY")}"}
      ],
      body:  %{
        "Text" => sms_notification.message_content,
        "To" => sms_notification.recipient_phone_number,
        "From" => "Atunelogy"} |> Poison.encode!
    )
    IO.inspect response
  end

  # TODO: This one will never match says dialyzer
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
