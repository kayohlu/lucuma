defmodule LucumaWeb.SessionController do
  use LucumaWeb, :controller

  alias Lucuma.Accounts
  alias Lucuma.Accounts.User
  alias Comeonin.Bcrypt

  plug :put_layout, {LucumaWeb.LayoutView, :only_form} when action in [:new, :create]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => params}) do
    potential_user = Accounts.get_user_by_email(params["email"])

    case Bcrypt.check_pass(potential_user, params["password"]) do
      {:ok, user} ->
        LucumaWeb.Plugs.Authentication.sign_in_user(conn, user)
        |> redirect(to: Routes.dashboard_path(conn, :show))

      {:error, user} ->
        render(conn, "new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
