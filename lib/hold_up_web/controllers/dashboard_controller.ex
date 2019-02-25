defmodule HoldUpWeb.DashboardController do
  use HoldUpWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
