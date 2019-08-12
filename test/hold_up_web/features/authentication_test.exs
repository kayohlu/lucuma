defmodule HoldUpWeb.Features.AuthenticationTest do
  use HoldUp.FeatureCase, async: false

  import HoldUp.Factory
  import Wallaby.Query

  describe "user logging in with valid data" do
    test "redirects to the dashboard", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, email: "a@a.com")
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: "a@a.com")
        |> fill_in(text_field("Password"), with: "123123123")

      page
      |> find(button("Sign In"))
      |> Wallaby.Element.click()

      page
      |> assert_text("Today")

      page
      |> find(css("#dropdownMenuButton", count: 1))
      |> Wallaby.Element.click()

      page
      |> click(link("Sign out"))
      |> find(link("Sign In"), &assert(has_text?(&1, "Sign In")))
      |> assert_text("Sign In")
    end
  end

  describe "user logging in with invalid data" do
    test "redirects to the dashboard", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, email: "a@a.com")
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)

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
