defmodule HoldUpWeb.WaitlistControllerTest do
  use HoldUpWeb.ConnCase

  alias HoldUp.Waitlists

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:waitlist) do
    {:ok, waitlist} = Waitlists.create_waitlist(@create_attrs)
    waitlist
  end

  describe "index" do
    test "lists all waitlists", %{conn: conn} do
      conn = get(conn, Routes.waitlist_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Wait lists"
    end
  end

  describe "new waitlist" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.waitlist_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wait list"
    end
  end

  describe "create waitlist" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.waitlist_path(conn, :create), waitlist: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.waitlist_path(conn, :show, id)

      conn = get(conn, Routes.waitlist_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Wait list"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.waitlist_path(conn, :create), waitlist: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wait list"
    end
  end

  describe "edit waitlist" do
    setup [:create_waitlist]

    test "renders form for editing chosen waitlist", %{conn: conn, waitlist: waitlist} do
      conn = get(conn, Routes.waitlist_path(conn, :edit, waitlist))
      assert html_response(conn, 200) =~ "Edit Wait list"
    end
  end

  describe "update waitlist" do
    setup [:create_waitlist]

    test "redirects when data is valid", %{conn: conn, waitlist: waitlist} do
      conn = put(conn, Routes.waitlist_path(conn, :update, waitlist), waitlist: @update_attrs)
      assert redirected_to(conn) == Routes.waitlist_path(conn, :show, waitlist)

      conn = get(conn, Routes.waitlist_path(conn, :show, waitlist))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, waitlist: waitlist} do
      conn = put(conn, Routes.waitlist_path(conn, :update, waitlist), waitlist: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Wait list"
    end
  end

  describe "delete waitlist" do
    setup [:create_waitlist]

    test "deletes chosen waitlist", %{conn: conn, waitlist: waitlist} do
      conn = delete(conn, Routes.waitlist_path(conn, :delete, waitlist))
      assert redirected_to(conn) == Routes.waitlist_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.waitlist_path(conn, :show, waitlist))
      end
    end
  end

  defp create_waitlist(_) do
    waitlist = fixture(:waitlist)
    {:ok, waitlist: waitlist}
  end
end
