defmodule RestaurantWeb.StandByControllerTest do
  use RestaurantWeb.ConnCase

  alias Restaurant.WaitLists

  @create_attrs %{contact_phone_number: "some contact_phone_number", estimated_wait_time: 42, name: "some name", notes: "some notes", party_size: 42}
  @update_attrs %{contact_phone_number: "some updated contact_phone_number", estimated_wait_time: 43, name: "some updated name", notes: "some updated notes", party_size: 43}
  @invalid_attrs %{contact_phone_number: nil, estimated_wait_time: nil, name: nil, notes: nil, party_size: nil}

  def fixture(:stand_by) do
    {:ok, stand_by} = WaitLists.create_stand_by(@create_attrs)
    stand_by
  end

  describe "index" do
    test "lists all stand_bys", %{conn: conn} do
      conn = get(conn, Routes.stand_by_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Stand bys"
    end
  end

  describe "new stand_by" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.stand_by_path(conn, :new))
      assert html_response(conn, 200) =~ "New Stand by"
    end
  end

  describe "create stand_by" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.stand_by_path(conn, :create), stand_by: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.stand_by_path(conn, :show, id)

      conn = get(conn, Routes.stand_by_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Stand by"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.stand_by_path(conn, :create), stand_by: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Stand by"
    end
  end

  describe "edit stand_by" do
    setup [:create_stand_by]

    test "renders form for editing chosen stand_by", %{conn: conn, stand_by: stand_by} do
      conn = get(conn, Routes.stand_by_path(conn, :edit, stand_by))
      assert html_response(conn, 200) =~ "Edit Stand by"
    end
  end

  describe "update stand_by" do
    setup [:create_stand_by]

    test "redirects when data is valid", %{conn: conn, stand_by: stand_by} do
      conn = put(conn, Routes.stand_by_path(conn, :update, stand_by), stand_by: @update_attrs)
      assert redirected_to(conn) == Routes.stand_by_path(conn, :show, stand_by)

      conn = get(conn, Routes.stand_by_path(conn, :show, stand_by))
      assert html_response(conn, 200) =~ "some updated contact_phone_number"
    end

    test "renders errors when data is invalid", %{conn: conn, stand_by: stand_by} do
      conn = put(conn, Routes.stand_by_path(conn, :update, stand_by), stand_by: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Stand by"
    end
  end

  describe "delete stand_by" do
    setup [:create_stand_by]

    test "deletes chosen stand_by", %{conn: conn, stand_by: stand_by} do
      conn = delete(conn, Routes.stand_by_path(conn, :delete, stand_by))
      assert redirected_to(conn) == Routes.stand_by_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.stand_by_path(conn, :show, stand_by))
      end
    end
  end

  defp create_stand_by(_) do
    stand_by = fixture(:stand_by)
    {:ok, stand_by: stand_by}
  end
end
