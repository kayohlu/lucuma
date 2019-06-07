defmodule HoldUpWeb.Features.SubscriptionTest do
  use HoldUp.FeatureCase, async: false

  import HoldUp.Factory
  import Wallaby.Query

  def register_user(session) do
    session
      |> visit("/")
      |> find(link("Choose plan", count: 3, at: 1), & assert has_text?(&1, "Choose plan"))
      |> click(link("Choose plan", count: 3, at: 1))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
  end

  describe "user skips subscription via the registration form" do
    test "redirects to the dashboard", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")


      session
      |> click(link("skip"))
      |> assert_text("That's it. Your registration is complete. We've created an initial default waitlist for you. You can add up to 100 people to your waitlist.")
    end
  end

  describe "user skips subscription via the profile page" do
    test "redirects to the profile page", %{session: session} do
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

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click

      page
      |> click(link("Profile"))
      |> click(link("Choose plan", count: 3, at: 0))
      |> click(link("skip"))

      page
      |> find(css(".alert"), & assert has_css?(&1, css(".alert")))
      |> assert_text("You are currently using the free trial. You can add up to 100 customers to your waitlist.")
    end
  end

  describe "user subscribes via the registration form" do
    test "redirects to the dashboard", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4242424242424242 12 23 346 90210")

      session
      |> click(button("Subscribe"))

      # Fuck it, I had to put a sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(1500)

      session
      |> find(Wallaby.Query.text("Dashboard"), & assert has_text?(&1, "Dashboard"))
      |> assert_text("You're subscription has now been activated. To cancel or change your plan, visit your profile.")
    end
  end

  describe "user enters an invalid cc number(4000000000000341), attaching this card to a Customer object succeeds, but attempts to charge the customer fail" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000341 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000009235), results in a charge with a risk_level of elevated" do
    test "redirects successfully", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000009235 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("You're subscription has now been activated. To cancel or change your plan, visit your profile.")
    end
  end


  describe "user enters a valid cc number(4000000000004954), results in a charge with a risk_level of highest" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000004954 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4100000000000019), results in a charge with a risk_level of highest. The charge is blocked as it's considered fraudulent" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4100000000000019 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000000002), charge is declined with a card_declined code." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")

      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000002 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
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


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000009995 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end

  describe "user enters a valid cc number(4000000000009987), charge is declined with a card_declined code. The decline_code attribute is lost_card" do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000009987 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
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


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000009979 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
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


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000069 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
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


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000127 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
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


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000119 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Could not process your subscription at this time. Please try again.")
    end
  end

  describe "user enters a valid cc number(4242424242424241), charge is declined with an incorrect_number code as the card number fails the Luhn check." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4242424242424241 12 23 346 90210")
      |> click(button("Subscribe"))
      |> assert_text("Your card number is invalid.")
    end
  end

  describe "user enters a valid cc number(4000000000000101), the cvc_check fails because we are blocking payments that fail CVC code validation, the charge is declined." do
    test "renders the payment form with appropriate error message", %{session: session} do
      register_user(session)
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000101 12 23 346 90210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to putaa sleep in here because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enough to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Your card CVC is wrong. Please try again.")
    end
  end


  ##################### 3D Secure Tests ###########################
end
