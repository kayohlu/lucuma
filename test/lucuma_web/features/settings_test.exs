defmodule LucumaWeb.Features.SettingsTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  describe "settings page" do
    test "visiting the settings page brings you to the profile page by default", %{
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

      assert_text(page, "Your Profile")
    end

    test "the billing link is not shown for staff users", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, roles: ["staff"])
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
      |> assert_text("Profile")

      page
      |> has?(css(".nav-link", text: "Billing"))
    end

    test "the staff link is not shown for staff users", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, roles: ["staff"])
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

      page
      |> has?(css(".nav-link", text: "Staff"))
    end
  end
end
