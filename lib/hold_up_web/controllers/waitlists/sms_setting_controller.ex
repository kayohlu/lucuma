defmodule HoldUpWeb.Waitlists.SmsSettingController do
  use HoldUpWeb, :controller

  plug :put_layout, :waitlist

  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.Waitlist

  def index(conn, _params) do
    waitlist = Waitlists.get_waitlist!(1)
    render(conn, "index.html", waitlist: waitlist)
  end
end
