defmodule HoldUpWeb.Plugs.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  alias HoldUp.Accounts
  alias PushWeb.Router.Helpers

  def authenticate_user(conn, _params) do
    user = Accounts.get_user!(get_session(conn, :current_user_id))

    if user do
      %{ conn | :assigns => Map.put(conn.assigns, :current_user, user) }
    else
      conn
      |> put_flash(:error, "You are not signed in. Please sign in to continue.")
      |> redirect(to: Helpers.session_path(conn, :new))
      |> halt()
    end
  end
end