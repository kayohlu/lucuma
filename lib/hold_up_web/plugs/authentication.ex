defmodule HoldUpWeb.Plugs.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  alias HoldUp.Accounts
  alias HoldUpWeb.Router.Helpers

  def authenticated?(conn, _params) do
    with {:ok, current_user_id} <- fetch_current_user_id(conn),
         {:ok, user } <- fetch_current_user(current_user_id)
    do
      %{ conn | :assigns => Map.put(conn.assigns, :current_user, user) }
    else
      {:not_found, _} -> redirect_to_root(conn)
    end
  end

  def redirect_to_root(conn) do
    conn
    |> put_flash(:error, "You are not signed in. Please sign in to continue.")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  def fetch_current_user_id(conn) do
    case get_session(conn, :current_user_id) do
      nil -> {:not_found, "current_user_id not in session"}
      current_user_id -> {:ok, current_user_id}
    end
  end

  def fetch_current_user(current_user_id) do
    case Accounts.get_user(current_user_id) do
      nil -> {:not_found, "current_user not in db"}
      user -> {:ok, user}
    end
  end
end