defmodule HoldUpWeb.RegistrationController do
  use HoldUpWeb, :controller

  alias HoldUp.Registrations
  alias HoldUp.Registrations.RegistrationForm

  plug :put_layout, false when action in [:new]

  @type schema :: Ecto.Schema.t()
  @type conn :: Plug.Conn.t()
  @type params :: Map.t()

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
        |> put_flash(
          :info,
          "That's it. Your registration is complete. We've created an initial default waitlist for you."
        )
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
