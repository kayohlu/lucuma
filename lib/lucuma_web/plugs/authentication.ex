defmodule LucumaWeb.Plugs.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  alias Lucuma.Accounts
  alias LucumaWeb.Router.Helpers

  def authenticated?(conn, _params) do
    with {:ok, current_user_id} <- fetch_current_user_id(conn),
         {:ok, user} <- fetch_current_user(current_user_id) do
      %{conn | :assigns => Map.put(conn.assigns, :current_user, user)}
    else
      {:not_found, _} ->
        conn
        |> delete_session(:current_user_id)
        |> redirect_to_root
    end
  end

  def sign_in_user(conn, user) do
    conn
    |> put_session(:current_user_id, user.id)
    |> put_session(:current_company_id, user.company.id)
    |> put_session(:current_business_id, hd(user.company.businesses).id)
  end

  defp redirect_to_root(conn) do
    conn
    |> put_flash(:error, "You are not signed in. Please sign in to continue.")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  defp fetch_current_user_id(conn) do
    case get_session(conn, :current_user_id) do
      nil -> {:not_found, "current_user_id not in session"}
      current_user_id -> {:ok, current_user_id}
    end
  end

  defp fetch_current_user(current_user_id) do
    case Accounts.get_user(current_user_id) do
      nil -> {:not_found, "current_user not in db"}
      user -> {:ok, user}
    end
  end
end
