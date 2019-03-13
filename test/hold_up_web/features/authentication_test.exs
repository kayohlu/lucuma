defmodule HoldUpWeb.Features.AuthenticationTest do
  use HoldUp.FeatureCase, async: true

  import HoldUp.Factory
  import Wallaby.Query

  describe "user logging in with valid data" do
    test "redirects to the dashboard", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, email: "a@a.com")

      session
      |> visit("/")
      |> click(link("Sign In"))
      |> fill_in(text_field("Email"), with: "a@a.com")
      |> fill_in(text_field("Password"), with: "123123123")
      |> click(button("Sign In"))
      |> assert_text("Dashboard")

      # logout

      session
      |> click(link("Log out"))
      |> assert_text("Sign In")
    end
  end

  describe "user logging in with invalid data" do
    test "redirects to the dashboard", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, email: "a@a.com")

      session
      |> visit("/")
      |> click(link("Sign In"))
      |> fill_in(text_field("Email"), with: "not_a_user@a.com")
      |> fill_in(text_field("Password"), with: "12312312")
      |> click(button("Sign In"))
      |> assert_text("Sign In")
    end
  end
end
