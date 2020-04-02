defmodule LucumaWeb.Features.LimitTrialAccountsTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  describe "adding somone to a waitlist when the trial limit has been reached" do
    test "it does not allow a user to add someone to the waitlist", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      insert_list(100, :stand_by, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))

      assert_text(page, "Today")

      page =
        page
        |> click(link("Waitlist"))
        |> find(button("Add Person"), &assert(has_text?(&1, "Add Person")))
        |> click(button("Add Person"))

      refute_has(page, text_field("Name"))
      refute_has(page, text_field("Contact phone number"))
      refute_has(page, text_field("Party size"))
      refute_has(page, text_field("Estimated wait time"))
      refute_has(page, text_field("Notes"))

      assert_text(page, "You have reached your trial limit.")
    end
  end

  describe "adding somone to a waitlist when the trial limit has been reached but a subscription is active" do
    test "it does not allow a user to add someone to the waitlist", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      insert_list(100, :stand_by, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))

      assert_text(page, "Today")

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      page
      |> click(link("Settings"))
      |> find(link("Billing"), &assert(has_text?(&1, "Billing")))
      |> click(link("Billing"))
      |> click(link("Choose plan", count: 3, at: 0))
      |> assert_text("Subscription")

      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click()

      session
      |> send_keys("4111111111111111122334690210")
      |> click(button("Subscribe"))

      page =
        page
        |> click(link("Waitlist"))
        |> find(button("Add Person"), &assert(has_text?(&1, "Add Person")))
        |> click(button("Add Person"))
        |> fill_in(text_field("Name"), with: "name")
        |> fill_in(text_field("Contact phone number"), with: "+353851761516")
        |> fill_in(text_field("Party size"), with: "2")
        |> fill_in(text_field("Estimated wait time"), with: "12")
        |> fill_in(text_field("Notes"), with: "a note")
        |> click(css(".btn.btn-primary", text: "Add", count: 2, at: 1))

      assert_text(page, "+353851761516")

      page
      |> refute_has(Query.text("You have reached your trial limit."))

      assert Lucuma.Waitlists.Analytics.total_waitlisted(waitlist.id, business) == 101
    end
  end
end
