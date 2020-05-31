defmodule LucumaWeb.Features.ProfileTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  describe "when the user wants to edit their profile information" do
    test "updates their info successfully", %{
      session: session
    } do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> click(button("Sign In"))

      assert_text(page, "Today")

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      page
      |> click(link("Settings"))
      |> find(css(".nav-link.active", count: 1))
      |> assert_text("Profile")

      assert_text(page, "Profile")

      page
      |> fill_in(text_field("Email"), with: "b@b.com")
      |> fill_in(text_field("Full name"), with: "aa bb")
      |> click(button("Update profile"))

      assert_text(page, "Profile update successfully.")

      updated_user = Repo.get!(Lucuma.Accounts.User, user.id)

      assert updated_user.email == "b@b.com"
      assert updated_user.full_name == "aa bb"
    end
  end

  describe "when the user wants to change their password" do
    test "updates their password successfully", %{
      session: session
    } do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> click(button("Sign In"))

      assert_text(page, "Today")

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      page
      |> click(link("Settings"))
      |> find(css(".nav-link.active", count: 1))
      |> assert_text("Profile")

      assert_text(page, "Profile")

      page
      |> fill_in(text_field("user[password]"), with: "321321321")
      |> fill_in(text_field("user[password_confirmation]"), with: "321321321")
      |> click(button("Update password"))

      assert_text(page, "Password changed successfully.")

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      page
      |> click(link("Sign out"))
      |> find(link("Sign In"), &assert(has_text?(&1, "Sign In")))
      |> click(link("Sign In"))
      |> fill_in(text_field("Email"), with: user.email)
      |> fill_in(text_field("Password"), with: "321321321")
    end
  end
end
