defmodule HoldUp.Notifications.Notifier do
  alias HoldUp.Notifications
  alias HoldUpWeb.Router.Helpers
  alias HoldUpWeb.Waitlists


  def send_sms(recipient_phone_number, message_content, stand_by_id) do
    {:ok, sms_task_pid} =
      Task.start(fn ->
        {:ok, sms_notification} = Notifications.create_sms_notification(%{
          stand_by_id: stand_by_id,
          message_content: message_content,
          recipient_phone_number: recipient_phone_number
        })

        case Mix.env() do
          :prod ->
            [twilio_number_data] = ExTwilio.IncomingPhoneNumber.all()

            {:ok, response} =
              ExTwilio.Message.create(
                to: recipient_phone_number,
                from: twilio_number_data.phone_number,
                body: message_content,
                status_callback: Helpers.sms_status_url(HoldUpWeb.Endpoint, :create, sms_notification.id)
              )

          _ ->
            {:ok, response} =
              ExTwilio.Message.create(
                to: recipient_phone_number,
                from: System.get_env("TWILIO_DEV_FROM_NUMBER"),
                body: message_content
              )

            IO.inspect(response)
        end
      end)
  end
end