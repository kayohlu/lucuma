defmodule HoldUpWeb.StandBys.NotificationController do
  use HoldUpWeb, :controller

  alias HoldUp.Waitlists

  def create(conn, params) do
    Waitlists.notify_stand_by(params["stand_by_id"])

    conn
    |> redirect(to: Routes.waitlists_waitlist_path(conn, :index))
  end
end
