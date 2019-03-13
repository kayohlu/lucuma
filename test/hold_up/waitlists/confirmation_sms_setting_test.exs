defmodule HoldUp.WaitlistsTests.ConfirmationSmsSettingTest do
  use HoldUp.DataCase, async: true

  import HoldUp.Factory

  alias HoldUp.Waitlists
  alias HoldUp.Accounts

  describe "confirmation_sms_settings" do
    alias HoldUp.Waitlists.ConfirmationSmsSetting

    test "create_confirmation_sms_settings/1 with valid data creates a confirmation_sms_setting" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))

      confirmation_sms_setting_params = params_for(:confirmation_sms_setting)

      assert {:ok, %ConfirmationSmsSetting{} = confirmation_sms_setting} =
               Waitlists.create_confirmation_sms_setting(
                 Map.put(confirmation_sms_setting_params, :waitlist_id, waitlist.id)
               )

      assert confirmation_sms_setting.enabled == confirmation_sms_setting_params.enabled

      assert confirmation_sms_setting.message_content ==
               confirmation_sms_setting_params.message_content
    end

    test "create_confirmation_sms_settings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Waitlists.create_confirmation_sms_setting(%{enabled: nil})
    end

    test "update_confirmation_sms_settings/1 with valid data updates the confirmation_sms_setting" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))
      confirmation_sms_setting = insert(:confirmation_sms_setting, waitlist: waitlist)
      confirmation_sms_setting_params = params_for(:confirmation_sms_setting)

      assert {:ok, %ConfirmationSmsSetting{} = confirmation_sms_setting} =
               Waitlists.update_confirmation_sms_setting(
                 confirmation_sms_setting,
                 confirmation_sms_setting_params
               )

      assert confirmation_sms_setting.enabled == confirmation_sms_setting_params.enabled

      assert confirmation_sms_setting.message_content ==
               confirmation_sms_setting_params.message_content
    end

    test "update_confirmation_sms_settings/2 with invalid data returns error changeset" do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))
      confirmation_sms_setting = insert(:confirmation_sms_setting, waitlist: waitlist)

      assert {:error, %Ecto.Changeset{}} =
               Waitlists.update_confirmation_sms_setting(confirmation_sms_setting, %{enabled: nil})

      # assert confirmation_sms_setting == Waitlists.get_confirmation_sms_setting!(confirmation_sms_setting.id)
    end
  end
end
