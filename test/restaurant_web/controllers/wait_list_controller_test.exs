defmodule RestaurantWeb.WaitListControllerTest do
  use RestaurantWeb.ConnCase

  alias Restaurant.WaitLists

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:wait_list) do
    {:ok, wait_list} = WaitLists.create_wait_list(@create_attrs)
    wait_list
  end

  describe "index" do
    test "lists all wait_lists", %{conn: conn} do
      conn = get(conn, Routes.wait_list_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Wait lists"
    end
  end

  describe "new wait_list" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.wait_list_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wait list"
    end
  end

  describe "create wait_list" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.wait_list_path(conn, :create), wait_list: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.wait_list_path(conn, :show, id)

      conn = get(conn, Routes.wait_list_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Wait list"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.wait_list_path(conn, :create), wait_list: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wait list"
    end
  end

  describe "edit wait_list" do
    setup [:create_wait_list]

    test "renders form for editing chosen wait_list", %{conn: conn, wait_list: wait_list} do
      conn = get(conn, Routes.wait_list_path(conn, :edit, wait_list))
      assert html_response(conn, 200) =~ "Edit Wait list"
    end
  end

  describe "update wait_list" do
    setup [:create_wait_list]

    test "redirects when data is valid", %{conn: conn, wait_list: wait_list} do
      conn = put(conn, Routes.wait_list_path(conn, :update, wait_list), wait_list: @update_attrs)
      assert redirected_to(conn) == Routes.wait_list_path(conn, :show, wait_list)

      conn = get(conn, Routes.wait_list_path(conn, :show, wait_list))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, wait_list: wait_list} do
      conn = put(conn, Routes.wait_list_path(conn, :update, wait_list), wait_list: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Wait list"
    end
  end

  describe "delete wait_list" do
    setup [:create_wait_list]

    test "deletes chosen wait_list", %{conn: conn, wait_list: wait_list} do
      conn = delete(conn, Routes.wait_list_path(conn, :delete, wait_list))
      assert redirected_to(conn) == Routes.wait_list_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.wait_list_path(conn, :show, wait_list))
      end
    end
  end

  defp create_wait_list(_) do
    wait_list = fixture(:wait_list)
    {:ok, wait_list: wait_list}
  end
end
