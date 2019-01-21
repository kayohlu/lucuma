defmodule RestaurantWeb.StandByController do
  use RestaurantWeb, :controller

  alias Restaurant.WaitLists
  alias Restaurant.WaitLists.WaitList

  def new(conn, _params) do
    wait_list = WaitLists.get_wait_list!(1)
    render(conn, "new.html", wait_list: wait_list)
  end
end
