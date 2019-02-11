defmodule HoldUpWeb.StandBys.NotificationController do
  use HoldUpWeb, :controller

  alias HoldUp.WaitLists

  def create(conn, params) do
    wait_list = WaitLists.get_wait_list!(1)
    WaitLists.notify_stand_by(wait_list.id, params["stand_by_id"])

    conn
      |> redirect(to: Routes.wait_list_path(conn, :index))
  end
end