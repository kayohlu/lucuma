defmodule HoldUpWeb.DashboardControllerTest do
  use HoldUpWeb.ConnCase, async: true

  import HoldUp.Factory

  alias HoldUp.Dashboards

  describe "index" do
    test "show dashboard", %{conn: conn} do
      company = insert(:company)
    business = insert(:business, company: company)
    user = insert(:user, company: company)
    waitlist = insert(:waitlist, business: business)

    conn = Plug.Test.init_test_session(conn, current_user_id: user.id, current_business_id: business.id, current_company_id: company.id)


      conn = get(conn, Routes.dashboard_path(conn, :index))
      assert html_response(conn, 200) =~ "Dashboard"
    end
  end
end
