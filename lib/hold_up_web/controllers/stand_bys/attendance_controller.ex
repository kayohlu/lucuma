defmodule HoldUpWeb.StandBys.AttendanceController do
  use HoldUpWeb, :controller

  alias HoldUp.Waitlists

  def create(conn, params) do
    Waitlists.mark_as_attended(params["stand_by_id"])

    conn
    |> redirect(to: Routes.waitlist_path(conn, :index))
  end
end