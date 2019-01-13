defmodule RestaurantWeb.DashboardController do
  use RestaurantWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end