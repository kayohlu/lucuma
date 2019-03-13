defmodule HoldUpWeb.Features.WaitlistTest do
  use HoldUp.FeatureCase, async: false

  import HoldUp.Factory
  # , only: [css: 2]
  import Wallaby.Query

  describe "waitlists" do
    test "redirects to the only wailist in the business", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
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

      page
      |> click(link("Waitlist"))
      |> take_screenshot
    end
  end

  describe "adding a stand by to a waitlist" do
    test "redirects to the waitlist view successfully", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
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
        |> click(link("Add Person"))
        |> fill_in(text_field("Name"), with: "name")
        |> fill_in(text_field("Contact phone number"), with: "+353851761516")
        |> fill_in(text_field("Party size"), with: "2")
        |> fill_in(text_field("Estimated wait time"), with: "12")
        |> fill_in(text_field("Notes"), with: "a note")
        |> click(button("Add"))

      assert_text(page, "Stand by created successfully.")
      assert_text(page, "+353851761516")
      assert_has(page, link("Notify"))
      assert_has(page, link("No Show"))
      assert_has(page, link("Arrive"))

      find(page, css(".nav-link.active", count: 1))
      |> assert_text("Details")
    end
  end

  describe "editing waitlist settings" do
    test "editing the settings redirects you to the settings page", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
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

      page |> take_screenshot
    end
  end
end
