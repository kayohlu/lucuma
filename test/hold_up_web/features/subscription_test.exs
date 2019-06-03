defmodule HoldUpWeb.Features.SubscriptionTest do
  use HoldUp.FeatureCase, async: false

  import HoldUp.Factory
  import Wallaby.Query

  describe "user skips subscription via the registration form" do
    test "redirects to the dashboard", %{session: session} do
      page = session
      |> visit("/")
      |> click(link("Choose plan", count: 3, at: 1))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
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
      page = session
      |> visit("/")
      |> click(link("Choose plan", count: 3, at: 1))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4242424242424242122334690210")

      session
      |> click(button("Subscribe"))
      |> find(Wallaby.Query.text("Dashboard"), & assert has_text?(&1, "Dashboard"))
      |> assert_text("You're subscription has now been activated. To cancel or change your plan, visit your profile.")
    end
  end

  describe "user enters an invalid cc number(4000000000000341), attaching this card to a Customer object succeeds, but attempts to charge the customer fail" do
    test "renders the payment form with appropriate error message", %{session: session} do
      page = session
      |> visit("/")
      |> click(link("Choose plan", count: 3, at: 1))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
      |> assert_text("Subscription")


      session
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4000000000000341122334690210")
      |> click(button("Subscribe"))

      # |> find(css(".InputElement"), & assert has_css?(&1, css(".InputElement")))
      # Fuck it, I had to puta sleep in heere because it looks like some element isn't on the page yet for some reason
      # even though using find to block isn't blocking for long enought to check the text.
      :timer.sleep(2000)

      session
      |> assert_text("Subscription failed. Your card was declined. Please try another card.")
    end
  end
end
