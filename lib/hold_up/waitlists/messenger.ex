defmodule HoldUp.Waitlists.Messenger do
  def send_message(destination_phone_number, message_body) do
    case Mix.env do
      :prod ->
        [twilio_number_data] = ExTwilio.IncomingPhoneNumber.all

        ExTwilio.Message.create(to: destination_phone_number,
                                from: twilio_number_data.phone_number,
                                body: message_body)
      _ ->
        result = ExTwilio.Message.create(to: destination_phone_number,
                                from: System.get_env("TWILIO_DEV_FROM_NUMBER"),
                                body: message_body)

        IO.inspect(result)
    end

  end
end