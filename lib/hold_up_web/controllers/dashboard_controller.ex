defmodule HoldUpWeb.DashboardController do
  use HoldUpWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
