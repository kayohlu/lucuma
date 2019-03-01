defmodule HoldUpWeb.StandBys.CancellationController do
  use HoldUpWeb, :controller

  alias HoldUp.Waitlists

  def create(conn, params) do
    Waitlists.mark_as_cancelled(params["stand_by_id"])

    conn
    |> redirect(to: Routes.waitlists_waitlist_path(conn, :index))
  end
end