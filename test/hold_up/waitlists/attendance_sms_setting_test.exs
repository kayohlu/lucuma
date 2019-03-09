defmodule HoldUp.WaitlistsTests.AttendanceSmsSettingTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Waitlists
  alias HoldUp.Accounts

  describe "attendance_sms_settings" do
    alias HoldUp.Waitlists.AttendanceSmsSetting

    @valid_attrs %{
      enabled: true,
      message_content: "message content"
    }
    @update_attrs %{
      enabled: true,
      message_content: "updated message content"
    }
    @invalid_attrs %{
      enabled: nil,
      message_content: false
    }

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        %{
          name: "name",
          contact_email: "test@testcompany.com"
        }
        |> Accounts.create_company()

      company
    end

    def business_fixture(attrs \\ %{}) do
      {:ok, business} =
        attrs
        |> Enum.into(%{
          name: "business 1",
          company_id: company_fixture.id
        })
        |> Accounts.create_business()

      business
    end

    def waitlist_fixture(attrs \\ %{}) do
      {:ok, waitlist} =
        attrs
        |> Enum.into(%{
          name: "asdasd",
          business_id: business_fixture.id
        })
        |> Waitlists.create_waitlist()

      waitlist
    end

    def attendance_sms_setting_fixture(attrs \\ %{}) do
      {:ok, setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Waitlists.create_attendance_sms_setting()

      setting
    end

    test "create_attendance_sms_settings/1 with valid data creates a attendance_sms_setting" do
      waitlist = waitlist_fixture()

      assert {:ok, %AttendanceSmsSetting{} = attendance_sms_setting} =
               Waitlists.create_attendance_sms_setting(
                 Map.put(@valid_attrs, :waitlist_id, waitlist.id)
               )

      assert attendance_sms_setting.enabled == true
      assert attendance_sms_setting.message_content == "message content"
    end

    test "create_attendance_sms_settings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlists.create_attendance_sms_setting(@invalid_attrs)
    end

    test "update_attendance_sms_settings/1 with valid data updates the attendance_sms_setting" do
      attendance_sms_setting_fixture =
        attendance_sms_setting_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:ok, %AttendanceSmsSetting{} = attendance_sms_setting} =
               Waitlists.update_attendance_sms_setting(
                 attendance_sms_setting_fixture,
                 @update_attrs
               )

      assert attendance_sms_setting.enabled == true
      assert attendance_sms_setting.message_content == "updated message content"
    end

    test "update_attendance_sms_settings/2 with invalid data returns error changeset" do
      attendance_sms_setting = attendance_sms_setting_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:error, %Ecto.Changeset{}} =
               Waitlists.update_attendance_sms_setting(attendance_sms_setting, @invalid_attrs)

      # assert attendance_sms_setting == Waitlists.get_attendance_sms_setting!(attendance_sms_setting.id)
    end
  end
end
