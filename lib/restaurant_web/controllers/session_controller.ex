defmodule RestaurantWeb.SessionController do
  use RestaurantWeb, :controller

  alias Restaurant.Accounts
  alias Restaurant.Accounts.User
  alias Comeonin.Bcrypt

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{ "session" => params}) do
    potential_user = Accounts.get_user_by_email(params["email"])

    case Bcrypt.check_pass(potential_user, params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> redirect(to: Routes.page_path(conn, :index))
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
