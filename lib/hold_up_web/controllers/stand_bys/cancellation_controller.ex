defmodule HoldUpWeb.StandBys.CancellationController do
  use HoldUpWeb, :controller

  alias HoldUp.Waitlists

  def index(conn, params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => cancellation_uuid}) do
    Waitlists.mark_as_cancelled(cancellation_uuid)

    conn
    |> redirect(to: Routes.stand_bys_cancellation_path(conn, :index))
  end
end
