defmodule HoldUp.WaitlistsTests.ConfirmationSmsSettingTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Waitlists
  alias HoldUp.Accounts

  describe "confirmation_sms_settings" do
    alias HoldUp.Waitlists.ConfirmationSmsSetting

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

    def confirmation_sms_setting_fixture(attrs \\ %{}) do
      {:ok, setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Waitlists.create_confirmation_sms_setting()

      setting
    end

    test "create_confirmation_sms_settings/1 with valid data creates a confirmation_sms_setting" do
      waitlist = waitlist_fixture()

      assert {:ok, %ConfirmationSmsSetting{} = confirmation_sms_setting} =
               Waitlists.create_confirmation_sms_setting(
                 Map.put(@valid_attrs, :waitlist_id, waitlist.id)
               )

      assert confirmation_sms_setting.enabled == true
      assert confirmation_sms_setting.message_content == "message content"
    end

    test "create_confirmation_sms_settings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Waitlists.create_confirmation_sms_setting(@invalid_attrs)
    end

    test "update_confirmation_sms_settings/1 with valid data updates the confirmation_sms_setting" do
      confirmation_sms_setting_fixture =
        confirmation_sms_setting_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:ok, %ConfirmationSmsSetting{} = confirmation_sms_setting} =
               Waitlists.update_confirmation_sms_setting(
                 confirmation_sms_setting_fixture,
                 @update_attrs
               )

      assert confirmation_sms_setting.enabled == true
      assert confirmation_sms_setting.message_content == "updated message content"
    end

    test "update_confirmation_sms_settings/2 with invalid data returns error changeset" do
      confirmation_sms_setting =
        confirmation_sms_setting_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:error, %Ecto.Changeset{}} =
               Waitlists.update_confirmation_sms_setting(confirmation_sms_setting, @invalid_attrs)

      # assert confirmation_sms_setting == Waitlists.get_confirmation_sms_setting!(confirmation_sms_setting.id)
    end
  end
end
