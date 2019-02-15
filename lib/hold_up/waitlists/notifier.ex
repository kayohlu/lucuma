defmodule HoldUp.Waitlists.Notifier do
  def send_sms(destination_phone_number, message_body) do
    case Mix.env() do
      :prod ->
        send_sms_task =
          Task.start(fn ->
            [twilio_number_data] = ExTwilio.IncomingPhoneNumber.all()

            {:ok, response} = ExTwilio.Message.create(
              to: destination_phone_number,
              from: twilio_number_data.phone_number,
              body: message_body,
              status_callback: ""
            )
          end)

      _ ->
        {:ok, response} =
          ExTwilio.Message.create(
            to: destination_phone_number,
            from: System.get_env("TWILIO_DEV_FROM_NUMBER"),
            body: message_body
          )

        IO.inspect(response)
    end
  end

  defp create_sms_notification
end