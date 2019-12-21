defmodule Lucuma.WaitlistsTests.AttendanceSmsSettingTest do
  use Lucuma.DataCase, async: true

  import Lucuma.Factory

  alias Lucuma.Waitlists
  alias Lucuma.Accounts

  describe "attendance_sms_settings" do
    alias Lucuma.Waitlists.AttendanceSmsSetting

    test "create_attendance_sms_settings/1 with valid data creates a attendance_sms_setting" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))

      attendance_sms_setting_params = params_for(:attendance_sms_setting)

      assert {:ok, %AttendanceSmsSetting{} = attendance_sms_setting} =
               Waitlists.create_attendance_sms_setting(
                 Map.put(attendance_sms_setting_params, :waitlist_id, waitlist.id)
               )

      assert attendance_sms_setting.enabled == attendance_sms_setting_params.enabled

      assert attendance_sms_setting.message_content ==
               attendance_sms_setting_params.message_content
    end

    test "create_attendance_sms_settings/1 with invalid data returns error changeset" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))

      assert {:error, %Ecto.Changeset{}} =
               Waitlists.create_attendance_sms_setting(%{enabled: nil, waitlist_id: waitlist.id})
    end

    test "update_attendance_sms_settings/1 with valid data updates the attendance_sms_setting" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))
      attendance_sms_setting = insert(:attendance_sms_setting, waitlist: waitlist)
      attendance_sms_setting_params = params_for(:attendance_sms_setting)

      assert {:ok, %AttendanceSmsSetting{} = attendance_sms_setting} =
               Waitlists.update_attendance_sms_setting(
                 attendance_sms_setting,
                 attendance_sms_setting_params
               )

      assert attendance_sms_setting.enabled == attendance_sms_setting_params.enabled

      assert attendance_sms_setting.message_content ==
               attendance_sms_setting_params.message_content
    end

    test "update_attendance_sms_settings/2 with invalid data returns error changeset" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))
      attendance_sms_setting = insert(:attendance_sms_setting, waitlist: waitlist)

      assert {:error, %Ecto.Changeset{}} =
               Waitlists.update_attendance_sms_setting(attendance_sms_setting, %{enabled: nil})

      # assert attendance_sms_setting == Waitlists.get_attendance_sms_setting!(attendance_sms_setting.id)
    end
  end
end
