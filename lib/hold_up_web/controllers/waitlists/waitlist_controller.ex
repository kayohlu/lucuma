defmodule HoldUpWeb.Waitlists.WaitlistController do
  use HoldUpWeb, :controller

  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.StandBy
  alias Phoenix.LiveView

  plug :put_layout, :waitlist

  def index(conn, _params) do
    waitlist = Waitlists.get_business_waitlist(conn.assigns.current_business.id)
    redirect(conn, to: Routes.waitlists_waitlist_path(conn, :show, waitlist.id))
  end

  def show(conn, %{"id" => id}) do
    # Since this view is rendered inside a nested layout that makes use
    # of something in the assigns this is a little hack to stop liveview complaining.
    conn = assign(conn, :waitlist, Waitlists.get_waitlist!(id))
    conn = assign(conn, :stand_bys, Waitlists.get_waitlist_stand_bys(id))

    LiveView.Controller.live_render(
      conn,
      HoldUpWeb.Live.Waitlists.WaitlistView,
      session: %{
        current_user_id: conn.assigns.current_user.id,
        waitlist_id: id
      }
    )
  end
end
