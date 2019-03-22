defmodule HoldUpWeb.Features.WaitlistTest do
  use HoldUp.FeatureCase, async: true

  import HoldUp.Factory
  import Wallaby.Query

  describe "waitlists" do
    test "redirects to the only wailist in the business", %{session: session} do
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
        |> find(button("Sign In"), & assert has_text?(&1, "Sign In"))
        |> click(button("Sign In"))

      assert_text(page, "Dashboard")

      page
      |> click(link("Waitlist"))
    end
  end

  describe "editing waitlist settings" do
    test "editing the settings redirects you to the settings page", %{session: session} do
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

      assert_text(page, "Dashboard")

      page =
        page
        |> click(link("Waitlist"))
        |> take_screenshot
        |> find(link("Settings"), & assert has_text?(&1, "Settings"))
        |> click(link("Settings"))

      find(page, css(".nav-link.active", count: 1))
      |> assert_text("Settings")

      element =
        page
        |> find(css(".btn.btn-primary.active.js_submitOnClick", count: 2))
        |> List.first()
        |> Wallaby.Element.click()

      find(page, css(".btn.btn-light.js_submitOnClick", count: 1))
      |> assert_text("Off")

      assert_text(page, "Settings updated successfully.")

      # Turn off the other setting

      page
      |> find(css(".btn.btn-primary.active.js_submitOnClick", count: 1))
      |> Wallaby.Element.click()

      find(page, css(".btn.btn-light.js_submitOnClick", count: 2))
      |> List.last()
      |> assert_text("Off")

      assert_text(page, "Settings updated successfully.")

      # editing the message content

      page
      |> fill_in(text_field("confirmation_sms_setting[message_content]"),
        with: "updated confirmation message content"
      )
      |> find(button("Update SMS message", count: 2))
      |> List.first()
      |> Wallaby.Element.click()

      assert_text(page, "updated confirmation message content")
      assert_text(page, "Settings updated successfully.")

      page
      |> fill_in(text_field("attendance_sms_setting[message_content]"),
        with: "updated attendance message content"
      )
      |> find(button("Update SMS message", count: 2))
      |> List.last()
      |> Wallaby.Element.click()

      assert_text(page, "updated attendance message content")
      assert_text(page, "Settings updated successfully.")
    end
  end

  describe "trying to view a waitlist that does not belong to the user's business but another business for the same company" do
    test "it 404s", %{session: session}  do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      other_waitlist = insert(:waitlist, business: insert(:business, company: company))

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> click(button("Sign In"))

      assert_text(page, "Dashboard")

      page =
        page
        |> click(link("Waitlist"))


      take_screenshot(page)
      page
      |> assert_text("Settings")

      page
      |> visit("/waitlists/#{other_waitlist.id}")
      |> assert_text("Not Found")
    end
  end
end
