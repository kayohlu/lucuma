defmodule RestaurantWeb.RegistrationController do
  use RestaurantWeb, :controller

  alias Restaurant.Registrations
  alias Restaurant.Registrations.RegistrationForm

  @type schema :: Ecto.Schema.t
  @type conn :: Plug.Conn.t
  @type params :: Map.t

  @spec new(conn, params) :: conn
  def new(conn, _params) do
    changeset = Registrations.change_registration_form(%RegistrationForm{})
    render(conn, "new.html", changeset: changeset)
  end

  @spec new(conn, params) :: conn
  def create(conn, %{"registration" => registration_params}) do
    case Registrations.create_registration_form(registration_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "That's it. Your registration is now complete. We've created an initial default restaurant for you.")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end