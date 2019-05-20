defmodule HoldUpWeb.SessionController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts
  alias HoldUp.Accounts.User
  alias Comeonin.Bcrypt

  plug :put_layout, {HoldUpWeb.LayoutView, :only_form} when action in [:new, :create]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => params}) do
    potential_user = Accounts.get_user_by_email(params["email"])

    case Bcrypt.check_pass(potential_user, params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:current_company_id, user.company.id)
        |> put_session(:current_business_id, hd(user.company.businesses).id)
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, user} ->
        render(conn, "new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
