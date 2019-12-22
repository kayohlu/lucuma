defmodule LucumaWeb.Waitlists.WaitlistController do
  use LucumaWeb, :controller

  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.StandBy
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
      LucumaWeb.Live.Waitlists.WaitlistView,
      session: %{
        current_user_id: conn.assigns.current_user.id,
        waitlist_id: id,
        current_company: conn.assigns.current_company,
        trial_limit_reached: conn.assigns.trial_limit_reached
      }
    )
  end
end
