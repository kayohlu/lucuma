defmodule LucumaWeb.StandBys.AttendanceController do
  use LucumaWeb, :controller

  alias Lucuma.Waitlists

  def create(conn, params) do
    Waitlists.mark_as_attended(params["stand_by_id"])

    conn
    |> redirect(to: Routes.waitlists_waitlist_path(conn, :index))
  end
end
