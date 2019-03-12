defmodule HoldUpWeb.RegistrationControllerTest do
  use HoldUpWeb.ConnCase, async: true

  alias HoldUp.Registrations

  @create_attrs %{
      email: "some@email",
      full_name: "some full_name",
      company_name: "company",
      password: "some password",
      password_confirmation: "some password"
    }
    @invalid_attrs %{
      email: nil,
      full_name: nil,
      password: nil,
      password_confirmation: nil
    }

  describe "new registration" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :new))
      assert html_response(conn, 200) =~ "Register now"
    end
  end

  describe "create registration" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @create_attrs)

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
      assert %{"info" => "That's it. Your registration is complete. We've created an initial default waitlist for you."} = get_flash(conn)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @invalid_attrs)
      assert html_response(conn, 200) =~ "Register now"
    end
  end
end
