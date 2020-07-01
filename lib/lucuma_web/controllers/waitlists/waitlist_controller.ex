defmodule LucumaWeb.Waitlists.WaitlistController do
  use LucumaWeb, :controller

  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.Waitlist
  alias Lucuma.Waitlists.StandBy
  alias Phoenix.LiveView

  plug :put_layout, {LucumaWeb.LayoutView, :waitlist}

  def index(conn, _params) do
    waitlists = Waitlists.business_waitlists(conn.assigns.current_business.id)

    render(conn, "index.html", waitlists: waitlists)
    # redirect(conn, to: Routes.waitlists_waitlist_path(conn, :show, waitlist.id))
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
        "current_user_id" => conn.assigns.current_user.id,
        "waitlist_id" => id,
        "current_company" => conn.assigns.current_company,
        "trial_limit_reached" => conn.assigns.trial_limit_reached
      }
    )
  end

  def new(conn, _params) do
    changeset = Waitlists.change_waitlist(%Waitlist{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"waitlist" => waitlist_params} = params) do
    case Waitlists.create_waitlist(
           Map.put(waitlist_params, "business_id", conn.assigns.current_business.id)
         ) do
      {:ok, waitlist} ->
        redirect(conn, to: Routes.waitlists_waitlist_path(conn, :show, waitlist.id))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def waitlist(conn, %{"waitlist" => waitlist_params} = params) do
    waitlist = Waitlists.get_waitlist!(params["id"])

    case Waitlists.create_waitlist(
           Map.put(waitlist_params, "business_id", conn.assigns.current_business.id)
         ) do
      {:ok, waitlist} ->
        redirect(conn, to: Routes.waitlists_waitlist_path(conn, :show, waitlist.id))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
