defmodule HoldUpWeb.Plugs.Authorisation do
  import Plug.Conn
  alias HoldUp.Waitlists
  import Canada, only: [can?: 2]
  use Phoenix.Controller

  def authorise(conn, _params) do
    check_waitlist_authorisation(conn, conn.params["waitlist_id"])
  end

  defp check_waitlist_authorisation(conn, nil) do
    conn
  end
  defp check_waitlist_authorisation(conn, waitlist_id) do
    waitlist = Waitlists.get_waitlist!(waitlist_id)

    conn
    |> handle_permission(conn.assigns.current_business |> can? read(waitlist))
  end

  defp handle_permission(conn, true) do
    conn
  end
  defp handle_permission(conn, false) do
    conn
    |> put_status(:not_found)
    |> put_view(HoldUpWeb.ErrorView)
    |> put_layout({HoldUpWeb.LayoutView, :app})
    |> render(:"404")
    |> halt()
  end
end
