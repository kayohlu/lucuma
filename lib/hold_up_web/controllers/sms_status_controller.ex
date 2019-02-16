defmodule HoldUpWeb.SmsStatusController do
  use HoldUpWeb, :controller

  alias HoldUp.Notifications

  def create(conn, %{"sms_notification_id" => sms_notification_id, "MessageStatus" => message_status} = params) do
    sms_notification = Notifications.get_sms_notification!(sms_notification_id)

    case message_status do
      "delivered" -> Notifications.update_sms_notification(sms_notification, %{delivered_at: DateTime.utc_now})
      _ -> nil
    end

    conn
    |> send_resp(200, "")
  end
end