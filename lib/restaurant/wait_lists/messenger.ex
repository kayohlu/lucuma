defmodule Restaurant.WaitLists.Messenger do
  def send_message(destination_phone_number, message_body) do
    [twilio_number_data] = ExTwilio.IncomingPhoneNumber.all

    ExTwilio.Message.create(to: destination_phone_number,
                            from: twilio_number_data.phone_number,
                            body: message_body)
  end
end