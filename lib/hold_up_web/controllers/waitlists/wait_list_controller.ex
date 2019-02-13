defmodule HoldUpWeb.Waitlists.WaitlistController do
  use HoldUpWeb, :controller

  plug :put_layout, :waitlist

  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.Waitlist

  def index(conn, _params) do
    waitlist = Waitlists.get_waitlist!(1)
    party_breakdown = Waitlists.party_size_breakdown(waitlist.stand_bys)
    average_wait_time = Waitlists.calculate_average_wait_time(waitlist.id)
    render(conn, "index.html", waitlist: waitlist, party_breakdown: party_breakdown, average_wait_time: average_wait_time)
  end
end