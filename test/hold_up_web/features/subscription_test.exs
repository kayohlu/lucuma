defmodule HoldUpWeb.Features.SubscriptionTest do
  use HoldUp.FeatureCase, async: true

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
      |> find(Wallaby.Query.text("Credit or debit card"))
      |> Wallaby.Element.click

      session
      |> send_keys("4242424242424242122334690210")

      session
      |> click(button("Subscribe"))
      |> assert_text("You're subscription has now been activated.")
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
      |> assert_text("You're subscription has now been activated.")
    end
  end
end
