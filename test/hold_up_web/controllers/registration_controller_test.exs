defmodule HoldUpWeb.RegistrationControllerTest do
  use HoldUpWeb.ConnCase

  alias HoldUp.Registrations

  @create_attrs %{
    email: "some email",
    full_name: "some full_name",
    password: "some password",
    password_confirmation: "some password_confirmation"
  }
  @update_attrs %{
    email: "some updated email",
    full_name: "some updated full_name",
    password: "some updated password",
    password_confirmation: "some updated password_confirmation"
  }
  @invalid_attrs %{email: nil, full_name: nil, password: nil, password_confirmation: nil}

  def fixture(:registration) do
    {:ok, registration} = Registrations.create_registration(@create_attrs)
    registration
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new registration" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :new))
      assert html_response(conn, 200) =~ "New Registration"
    end
  end

  describe "create registration" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.registration_path(conn, :show, id)

      conn = get(conn, Routes.registration_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Registration"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Registration"
    end
  end

  describe "edit registration" do
    setup [:create_registration]

    test "renders form for editing chosen registration", %{conn: conn, registration: registration} do
      conn = get(conn, Routes.registration_path(conn, :edit, registration))
      assert html_response(conn, 200) =~ "Edit Registration"
    end
  end

  describe "update registration" do
    setup [:create_registration]

    test "redirects when data is valid", %{conn: conn, registration: registration} do
      conn =
        put(conn, Routes.registration_path(conn, :update, registration),
          registration: @update_attrs
        )

      assert redirected_to(conn) == Routes.registration_path(conn, :show, registration)

      conn = get(conn, Routes.registration_path(conn, :show, registration))
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, registration: registration} do
      conn =
        put(conn, Routes.registration_path(conn, :update, registration),
          registration: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Registration"
    end
  end

  describe "delete registration" do
    setup [:create_registration]

    test "deletes chosen registration", %{conn: conn, registration: registration} do
      conn = delete(conn, Routes.registration_path(conn, :delete, registration))
      assert redirected_to(conn) == Routes.registration_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.registration_path(conn, :show, registration))
      end
    end
  end

  defp create_registration(_) do
    registration = fixture(:registration)
    {:ok, registration: registration}
  end
end
