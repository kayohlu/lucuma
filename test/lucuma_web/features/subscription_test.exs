defmodule LucumaWeb.Features.SubscriptionTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  def register_user(session) do
    session
    |> visit("/")

    # getting the odd intermittent failure.. prob some js
    :timer.sleep(300)

    session
    |> find(link("Choose plan", count: 3, at: 1), &assert(has_text?(&1, "Choose plan")))
    |> click(link("Choose plan", count: 3, at: 1))
    |> fill_in(text_field("Email"), with: "a@a.com")
    |> fill_in(text_field("Full name"), with: "user")
    |> fill_in(text_field("Company name"), with: "company")
    |> find(select("registration_time_zone"), &click(&1, option("Europe/Paris")))
    |> fill_in(text_field("registration[password]"), with: "123123123")
    |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
    |> click(button("Sign Up"))
  end

  def enter_cc_number_until_wallaby_gets_it_right(session, card_number) do
    enter_cc_number_until_wallaby_gets_it_right(session, card_number, false, 0)
  end

  def enter_cc_number_until_wallaby_gets_it_right(session, card_number, true, times) do
    IO.inspect({:enter_cc_number_until_wallaby_gets_it_right, true, times})

    session
    |> focus_default_frame

    session
  end

  def enter_cc_number_until_wallaby_gets_it_right(session, card_number, false, 100) do
    IO.inspect({:enter_cc_number_until_wallaby_gets_it_right, false, 100})

    session
    |> focus_default_frame

    session
  end

  def enter_cc_number_until_wallaby_gets_it_right(session, card_number, false, times) do
    IO.inspect({:enter_cc_number_until_wallaby_gets_it_right, false, times})
    n1 = String.slice(card_number, 0..3)
    n2 = String.slice(card_number, 4..7)
    n3 = String.slice(card_number, 8..11)
    n4 = String.slice(card_number, 12..15)

    session
    |> focus_frame(attribute("name", "__privateStripeFrame5", visible: :any))
    |> find(css("#root", visible: :any))
    |> fill_in(text_field("cardnumber"), with: n1)
    |> fill_in(text_field("cardnumber"), with: n2)
    |> fill_in(text_field("cardnumber"), with: n3)
    |> fill_in(text_field("cardnumber"), with: n4)

    cc_input_value =
      session
      |> find(css("#root", visible: :any))
      |> find(text_field("cardnumber"))
      |> Wallaby.Element.value()

    session
    |> focus_default_frame

    IO.inspect({:input_val, cc_input_value |> String.replace(" ", ""), :card_number, card_number})
    correct_or_not = cc_input_value |> String.replace(" ", "") == card_number
    enter_cc_number_until_wallaby_gets_it_right(session, card_number, correct_or_not, times + 1)
  end

  def fill_in_cc_form(session, card_number, expiry_date, cvc) do
    enter_cc_number_until_wallaby_gets_it_right(session, card_number)

    session
    |> focus_default_frame

    session
    |> focus_frame(attribute("name", "__privateStripeFrame6", visible: :any))
    |> find(css("#root", visible: :any))
    |> fill_in(text_field("exp-date", visible: :any), with: expiry_date)

    session
    |> focus_default_frame

    session
    |> focus_frame(attribute("name", "__privateStripeFrame7", visible: :any))
    |> find(css("#root", visible: :any))
    |> fill_in(text_field("cvc", visible: :any), with: cvc)

    session
    |> focus_default_frame
    |> take_screenshot

    session
  end

  describe "user skips subscription via the registration form" do
    test "redirects to the dashboard", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      session
      |> click(link("skip"))
      |> assert_text(
        "Your registration is complete. We've setup a waitlist for you. You can add up to 100 people to your waitlist before you need to subscribe."
      )
    end
  end

  describe "user skips subscription via the profile page" do
    test "redirects to the profile page", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, roles: ["company_admin"])
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
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      page
      |> click(link("Settings"))
      |> find(link("Billing"), &assert(has_text?(&1, "Billing")))
      |> click(link("Billing"))
      |> click(link("Choose plan", count: 3, at: 0))

      page
      |> click(link("skip"))

      page
      |> assert_text(
        "You are currently using the free trial. You can add up to 100 customers to your waitlist."
      )
    end
  end

  describe "user subscribes via the registration form" do
    test "redirects to the dashboard", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4111111111111111", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to put a sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(1000)

      session
      |> find(Wallaby.Query.text("Today"), &assert(has_text?(&1, "Today")))
      |> assert_text(
        "You're subscription has now been activated. To cancel or change your plan, visit your profile."
      )
    end
  end

  describe "user enters an invalid cc number(4000000000000341), attaching this card to a Customer object succeeds, but attempts to charge the customer fail (sub status == incomplete)" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000000341", "1223", "346")

      session
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(1500)

      session
      |> assert_text("Could not process your subscription at this time. Please try again.")
    end
  end

  describe "user enters a valid cc number(4000000000009235), results in a charge with a risk_level of elevated" do
    test "redirects successfully", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000009235", "1223", "346")

      session
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text(
        "You're subscription has now been activated. To cancel or change your plan, visit your profile."
      )
    end
  end

  describe "user enters a valid cc number(4000000000004954), results in a charge with a risk_level of highest (status == incomplete)" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000004954", "1223", "346")

      session
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(1000)

      session
      |> assert_text("Could not process your subscription at this time. Please try again.")
    end
  end

  # describe "user enters a valid cc number(4100000000000019), results in a charge with a risk_level of highest. The charge is blocked as it's considered fraudulent" do
  #   test "renders the payment form with appropriate error message", %{session: session} do
  #     register_user(session)
  #     |> assert_text("Subscription")

  #     session
  #     |> find(Wallaby.Query.text("Credit or debit card"))
  #     |> Wallaby.Element.click()

  #     # assert has_css?(session, ".InputElement")

  #     session
  #     |> send_keys("4100000000000019 12 23 346 90210")
  #     |> click(button("Subscribe"))

  #     # Fuck it, I had to put a sleep in here because it looks like some element isn't on the page yet for some reason
  #     # even though using find to block isn't blocking for long enough to check the text.
  #     :timer.sleep(2000)

  #     take_screenshot(session)

  #     session
  #     |> assert_text("Could not process your subscription at this time. Please try again.")
  #   end
  # end

  describe "user enters a valid cc number(4000000000000002), charge is declined with a card_declined code." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000000002", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000009995), charge is declined with a card_declined code. The decline_code attribute is insufficient_funds" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000009995", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> take_screenshot
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000009987), charge is declined with a card_declined code. The decline_code attribute is lost_card" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000009987", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000009979), charge is declined with a card_declined code. The decline_code attribute is stolen_card" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000009979", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000000069), charge is declined with an expired_card code" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000000069", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card has expired. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000000127), charge is declined with an incorrect_cvc code." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000000127", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card CVC is wrong. Please try again.")
    end
  end

  describe "user enters a valid cc number(4000000000000119), charge is declined with a processing_error code." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000000119", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(3000)

      session
      |> assert_text(
        "Subscription failed. Could not process your subscription at this time. Please try again."
      )
    end
  end

  # this card number is actually invalid because it fails the luhn check.
  # describe "user enters a valid cc number(4242424242424241), charge is declined with an incorrect_number code as the card number fails the Luhn check." do
  #   test "renders the payment form with appropriate error message", %{session: session} do
  #     register_user(session)
  #     |> assert_text("Subscription")

  #     fill_in_cc_form(session, "4242424242424241", "1223", "346")

  #     session
  #     |> assert_text("Your card number is invalid.")
  #   end
  # end

  describe "user enters a valid cc number(4000000000000101), the cvc_check fails because we are blocking payments that fail CVC code validation, the charge is declined." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4000000000000101", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to put a sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Your card CVC is wrong. Please try again.")
    end
  end

  ##################### START 3D Secure Tests ###########################
  ##################### END 3D Secure Tests ###########################

  describe "user cancels their subscription (metered pricing) via the profile page" do
    test "redirects to the profile page", %{session: session} do
      session
      |> visit("/")
      |> find(link("Choose plan", count: 3, at: 0), &assert(has_text?(&1, "Choose plan")))
      |> click(link("Choose plan", count: 3, at: 0))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> find(select("registration_time_zone"), &click(&1, option("Europe/Paris")))
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4111111111111111", "1223", "346")

      session
      |> click(button("Subscribe"))

      :timer.sleep(1000)

      session
      |> find(Wallaby.Query.text("Today"), &assert(has_text?(&1, "Today")))
      |> assert_text(
        "You're subscription has now been activated. To cancel or change your plan, visit your profile."
      )

      session
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      session
      |> click(link("Settings"))
      |> click(link("Billing"))
      |> find(link("Cancel"), &assert(has_text?(&1, "Cancel")))
      |> click(link("Cancel"))

      session
      |> assert_text("You're subscription has now been canceled.")

      session
      |> assert_text(
        "You are currently using the free trial. You can add up to 100 customers to your waitlist."
      )

      user = Lucuma.Accounts.get_user_by_email("a@a.com")
      company = user.company

      assert nil == company.stripe_subscription_id
      assert nil == company.stripe_payment_plan_id
    end
  end

  describe "user cancels their subscription (fixed pricing) via the profile page" do
    test "redirects to the profile page", %{session: session} do
      session
      |> visit("/")
      |> find(link("Choose plan", count: 3, at: 2), &assert(has_text?(&1, "Choose plan")))
      |> click(link("Choose plan", count: 3, at: 2))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> find(select("registration_time_zone"), &click(&1, option("Europe/Paris")))
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4111111111111111", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to put a sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(1000)

      session
      |> find(Wallaby.Query.text("Today's"), &assert(has_text?(&1, "Today's")))
      |> assert_text(
        "You're subscription has now been activated. To cancel or change your plan, visit your profile."
      )

      session
      # , &assert(has_css?(&1, css("#dropdownMenuButton", count: 1))))
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      session
      |> click(link("Settings"))
      |> click(link("Billing"))
      |> click(link("Cancel"))
      |> assert_text("You're subscription has now been canceled.")

      session
      |> assert_text(
        "You are currently using the free trial. You can add up to 100 customers to your waitlist."
      )

      user = Lucuma.Accounts.get_user_by_email("a@a.com")
      company = user.company

      assert nil == company.stripe_subscription_id
      assert nil == company.stripe_payment_plan_id
    end
  end

  describe "user upgrades their subscription (from metered to licensed) via the profile page" do
    test "redirects to the profile page", %{session: session} do
      session
      |> visit("/")
      |> find(link("Choose plan", count: 3, at: 0), &assert(has_text?(&1, "Choose plan")))
      |> click(link("Choose plan", count: 3, at: 0))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> find(select("registration_time_zone"), &click(&1, option("Europe/Paris")))
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
      |> assert_text("Subscription")

      fill_in_cc_form(session, "4111111111111111", "1223", "346")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to put a sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(1000)

      session
      |> find(Wallaby.Query.text("Today"), &assert(has_text?(&1, "Today")))
      |> assert_text(
        "You're subscription has now been activated. To cancel or change your plan, visit your profile."
      )

      session
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      session
      |> click(link("Settings"))
      |> click(link("Billing"))
      |> find(link("Upgrade", count: 2, at: 1), &assert(has_text?(&1, "Upgrade")))

      alert_message =
        accept_alert(session, fn session ->
          click(session, link("Upgrade", count: 2, at: 1))
        end)

      :timer.sleep(1000)

      session
      |> assert_text("You're subscription has now been updated.")

      user = Lucuma.Accounts.get_user_by_email("a@a.com")
      company = user.company

      assert "plan_F7YntQ0ELRD33U" == company.stripe_payment_plan_id
    end
  end
end
