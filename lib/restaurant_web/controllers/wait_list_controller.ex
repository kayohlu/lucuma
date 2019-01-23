defmodule RestaurantWeb.WaitListController do
  use RestaurantWeb, :controller

  alias Restaurant.WaitLists
  alias Restaurant.WaitLists.WaitList

  def index(conn, _params) do
    wait_list = WaitLists.get_wait_list!(1)
    party_breakdown = WaitLists.party_size_breakdown(wait_list.stand_bys)
    render(conn, "index.html", wait_list: wait_list, party_breakdown: party_breakdown)
  end
end
