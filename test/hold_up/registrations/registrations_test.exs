defmodule HoldUp.RegistrationsTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Registrations
  alias HoldUp.Registrations.RegistrationForm
  alias HoldUp.Accounts.User
  alias HoldUp.Accounts.Company
  alias HoldUp.Accounts.Business
  alias HoldUp.Waitlists.Waitlist
  alias HoldUp.Waitlists.ConfirmationSmsSetting
  alias HoldUp.Waitlists.AttendanceSmsSetting

  describe "registering" do
    alias HoldUp.Registrations.Registration

    @valid_attrs %{
      email: "some@email",
      full_name: "some full_name",
      company_name: "company",
      password: "some password",
      password_confirmation: "some password"
    }
    @invalid_attrs %{
      email: nil,
      full_name: nil,
      password: nil,
      password_confirmation: nil
    }

    test "create_registration_form/1 registers a user correctly and returns the user when the form is valid" do
      assert {:ok, %User{} = user} = Registrations.create_registration_form(@valid_attrs)

      assert Repo.one(from c in Company, where: c.id == ^user.company_id, select: count(c.id)) ==
               1

      assert Repo.one(
               from b in Business, where: b.company_id == ^user.company_id, select: count(b.id)
             ) == 1

      business = Repo.one(from b in Business, where: b.company_id == ^user.company_id)

      assert Repo.one(
               from w in Waitlist, where: w.business_id == ^business.id, select: count(w.id)
             ) == 1

      waitlist = Repo.one(from w in Waitlist, where: w.business_id == ^business.id)

      assert Repo.one(
               from css in ConfirmationSmsSetting,
                 where: css.waitlist_id == ^waitlist.id,
                 select: count(css.id)
             ) == 1

      assert Repo.one(
               from ass in AttendanceSmsSetting,
                 where: ass.waitlist_id == ^waitlist.id,
                 select: count(ass.id)
             ) == 1

      confirmation_sms_setting =
        Repo.one(from css in ConfirmationSmsSetting, where: css.waitlist_id == ^waitlist.id)

      assert confirmation_sms_setting.message_content == """
             Hello [[NAME]],

             You've been added to our waitlist. We'll let you know when it's your turn as soon as possible.

             Regards,
             Your friendly staff

             To cancel click the link below:
             [[CANCEL_LINK]]
             """

      attendance_sms_setting =
        Repo.one(from ass in AttendanceSmsSetting, where: ass.waitlist_id == ^waitlist.id)

      assert attendance_sms_setting.message_content == """
             Hello [[NAME]],

             It's your turn!

             Regards,
             Your friendly staff

             To cancel click the link below:
             [[CANCEL_LINK]]
             """
    end

    test "create_registration_form/1 returns the registration changeset when the form is invalid" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Registrations.create_registration_form(@invalid_attrs)

      assert changeset.action == :registration
    end

    test "change_registration_form/1 returns the registration changeset" do
      assert %Ecto.Changeset{} =
               changeset = Registrations.change_registration_form(%RegistrationForm{})
    end
  end
end
