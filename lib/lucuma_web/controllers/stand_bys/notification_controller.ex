defmodule LucumaWeb.StandBys.NotificationController do
  use LucumaWeb, :controller

  alias Lucuma.Waitlists

  def create(conn, params) do
    Waitlists.notify_stand_by(conn.assigns.current_business, params["stand_by_id"])

    conn
    |> redirect(to: Routes.waitlists_waitlist_path(conn, :index))
  end
end
