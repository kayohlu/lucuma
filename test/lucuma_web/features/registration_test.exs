defmodule LucumaWeb.Features.RegistrationTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  describe "registering with valid data" do
    test "redirects to the dashboard", %{session: session} do
      session
      |> visit("/")
      |> click(link("Sign Up"))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Full name"), with: "user")
      |> fill_in(text_field("Company name"), with: "company")

      session
      |> find(select("registration_time_zone"), &click(&1, option("Europe/Paris")))

      session
      |> fill_in(text_field("registration[password]"), with: "123123123")
      |> fill_in(text_field("registration[password_confirmation]"), with: "123123123")
      |> click(button("Sign Up"))
      |> assert_text("Today's highlights")
    end
  end

  describe "registering with invalid data" do
    test "redirects to the dashboard", %{session: session} do
      page =
        session
        |> visit("/")
        |> click(link("Sign Up"))
        |> fill_in(text_field("Email"), with: "aa.com")
        |> click(button("Sign Up"))

      assert_text(page, "has invalid format")
      assert_has(page, css(".invalid-feedback", count: 6))
    end
  end
end
