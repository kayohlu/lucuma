defmodule HoldUp.Factory do
  @moduledoc """
  https://thoughtbot.com/blog/announcing-ex-machina
  https://github.com/thoughtbot/ex_machina
  """
  use ExMachina.Ecto, repo: HoldUp.Repo

  def company_factory() do
    %HoldUp.Accounts.Company{
      name: sequence(:company_name, fn n -> "Company #{n}" end),
      contact_email: sequence(:company_email, fn n -> "email-company-#{n}@example.com" end)
    }
  end

  def user_factory(attrs) do
    %HoldUp.Accounts.User{
      email: sequence(:user_email, fn n -> "email-user-#{n}@example.com" end),
      full_name: sequence(:user_full_name, fn n -> "Full Name #{n}" end),
      password_hash: Comeonin.Bcrypt.hashpwsalt("123123123"),
      confirmation_sent_at: DateTime.utc_now(),
      confirmation_token: "some confirmation_token",
      confirmed_at: DateTime.utc_now() |> DateTime.add(3),
      reset_password_token: "some reset_password_token"
    }
    |> merge_attributes(attrs)
  end

  def business_factory(attrs) do
    %HoldUp.Accounts.Business{
      name: sequence(:business_name, fn n -> "Business #{n}" end)
    }
    |> merge_attributes(attrs)
  end

  def user_business_factory(attrs) do
    %HoldUp.Accounts.UserBusiness{}
    |> merge_attributes(attrs)
  end

  def waitlist_factory(attrs) do
    %HoldUp.Waitlists.Waitlist{
      name: sequence(:waitlist_name, fn n -> "Waitlist #{n}" end)
    }
    |> merge_attributes(attrs)
  end

  def confirmation_sms_setting_factory(attrs) do
    %HoldUp.Waitlists.ConfirmationSmsSetting{
      enabled: true,
      message_content: sequence(:waitlist_name, fn n -> "Message content #{n}" end)
      # waitlist: nil
    }
    |> merge_attributes(attrs)
  end

  def attendance_sms_setting_factory(attrs) do
    %HoldUp.Waitlists.AttendanceSmsSetting{
      enabled: true,
      message_content: sequence(:waitlist_name, fn n -> "Message content #{n}" end)
    }
    |> merge_attributes(attrs)
  end

  def stand_by_factory(attrs) do
    %HoldUp.Waitlists.StandBy{
      contact_phone_number: "+353851761516",
      estimated_wait_time: 20,
      name: sequence(:stand_by_name, fn n -> "Standby By name #{n}" end),
      notes: sequence(:stand_by_notes, fn n -> "A standby note #{n}" end),
      party_size: 3,
      cancellation_uuid: sequence(:stand_by_cancellation_uuid, fn n -> "cancel_uuid_#{n}" end)
    }
    |> merge_attributes(attrs)
  end

  def waitlist_factory(attrs) do
    %HoldUp.Waitlists.Waitlist{
      name: sequence(:waitlist_name, fn n -> "Waitlist #{n}" end)
    }
  end

  def sms_notification_factory(attrs) do
    %HoldUp.Notifications.SmsNotification{
      message_content: sequence(:sms_notification_message_content, fn n -> "Message content #{n}" end),
      recipient_phone_number: "+353861761516"
    }
  end
end
