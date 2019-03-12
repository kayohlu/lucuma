defmodule HoldUpWeb.StandByControllerTest do
  @moduledoc """
  NotificationProducer errors are thrown because of this test.
  This seems to be because the test process owns the db connection (process - i think it's a process) and when the test
  finishes the db connection no longer exists. So when the producer tries to make a query it fails because the connection
  no longer exists.
  See: https://elixirforum.com/t/issue-with-dbconnection-ownership-proxy-checkout-and-genserver-process/4334/2
  """
  use HoldUpWeb.ConnCase

  import HoldUp.Factory

  describe "new stand_by" do
    test "renders form", %{conn: conn} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      waitlist = insert(:waitlist, business: business)

      conn = Plug.Test.init_test_session(conn, current_user_id: user.id, current_business_id: business.id, current_company_id: company.id)
      conn = get(conn, Routes.waitlists_waitlist_stand_by_path(conn, :new, waitlist))

      assert html_response(conn, 200) =~ "New Stand by"
    end
  end

  describe "create stand_by" do
    test "redirects to show when data is valid", %{conn: conn} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      conn = Plug.Test.init_test_session(conn, current_user_id: user.id, current_business_id: business.id, current_company_id: company.id)
      conn = post(conn, Routes.waitlists_waitlist_stand_by_path(conn, :create, waitlist), stand_by: params_for(:stand_by))

      assert redirected_to(conn) == Routes.waitlists_waitlist_path(conn, :show, waitlist)

      # Hack to get around what is described in the moduledoc above. The test finished and the Notificationproducer is looking to use
      # a process/connection that does not exist anymore..
      :timer.sleep(10)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      waitlist = insert(:waitlist, business: business)

      conn = Plug.Test.init_test_session(conn, current_user_id: user.id, current_business_id: business.id, current_company_id: company.id)
      conn = post(conn, Routes.waitlists_waitlist_stand_by_path(conn, :create, waitlist), stand_by: %{name: nil})
      assert html_response(conn, 200) =~ "New Stand by"

      # Hack to get around what is described in the moduledoc above. The test finished and the Notificationproducer is looking to use
      # a process/connection that does not exist anymore..
      :timer.sleep(10)
    end
  end
  # describe "edit stand_by" do
  #   test "renders form for editing chosen stand_by", %{conn: conn} do
  #     company = insert(:company)
  #     business = insert(:business, company: company)
  #     user = insert(:user, company: company)
  #     waitlist = insert(:waitlist, business: business)
  #     stand_by = insert(:stand_by, waitlist: waitlist)

  #     conn = Plug.Test.init_test_session(conn, current_user_id: user.id, current_business_id: business.id, current_company_id: company.id)
  #     conn = get(conn, Routes.waitlists_waitlist_stand_by_path(conn, :edit, waitlist, stand_by))
  #     assert html_response(conn, 200) =~ "Edit Stand by"
  #   end
  # end

  # describe "update stand_by" do
  #   setup [:create_stand_by]

  #   test "redirects when data is valid", %{conn: conn, stand_by: stand_by} do
  #     company = insert(:company)
  #     business = insert(:business, company: company)
  #     user = insert(:user, company: company)
  #     waitlist = insert(:waitlist, business: business)

  #     conn = Plug.Test.init_test_session(conn, current_user_id: user.id, current_business_id: business.id, current_company_id: company.id)
  #     conn = put(conn, Routes.waitlists_waitlist_stand_by_path(conn, :update, waitlist, stand_by), stand_by: @update_attrs)

  #     assert redirected_to(conn) == Routes.waitlists_waitlist_stand_by_path(conn, :show, waitlist, stand_by)

  #     conn = get(conn, Routes.waitlists_waitlist_stand_by_path(conn, :show, waitlist, stand_by))

  #     assert html_response(conn, 200) =~ "some updated contact_phone_number"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, stand_by: stand_by} do
  #     conn = put(conn, Routes.stand_by_path(conn, :update, stand_by), stand_by: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit Stand by"
  #   end
  # end

  # describe "delete stand_by" do
  #   setup [:create_stand_by]

  #   test "deletes chosen stand_by", %{conn: conn, stand_by: stand_by} do
  #     conn = delete(conn, Routes.stand_by_path(conn, :delete, stand_by))
  #     assert redirected_to(conn) == Routes.stand_by_path(conn, :index)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.stand_by_path(conn, :show, stand_by))
  #     end
  #   end
  # end

  # defp create_stand_by(_) do
  #   stand_by = insert(:stand_by)
  #   {:ok, stand_by: stand_by}
  # end
end
