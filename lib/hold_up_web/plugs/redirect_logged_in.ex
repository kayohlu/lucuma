defmodule HoldUpWeb.Plugs.RedirectLoggedIn do
  import Plug.Conn
  import Phoenix.Controller
  alias HoldUpWeb.Router.Helpers

  def redirect_if_logged_in(conn, _params) do
    if get_session(conn, :current_user_id) do
      conn
      |> redirect(to: Helpers.dashboard_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
