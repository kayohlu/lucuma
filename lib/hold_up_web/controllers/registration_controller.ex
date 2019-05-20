defmodule HoldUpWeb.RegistrationController do
  use HoldUpWeb, :controller

  alias HoldUp.Registrations
  alias HoldUp.Registrations.RegistrationForm

  plug :put_layout, {HoldUpWeb.LayoutView, :only_form} when action in [:new, :create]

  @type schema :: Ecto.Schema.t()
  @type conn :: Plug.Conn.t()
  @type params :: Map.t()

  @spec new(conn, params) :: conn
  def new(conn, params) do
    changeset = Registrations.change_registration_form(%RegistrationForm{})
    render(conn, "new.html", changeset: changeset, payment_plan_id: payment_plan_id(params))
  end

  @spec new(conn, params) :: conn
  def create(conn, params) do
    %{"registration" => registration_params} = params
    case Registrations.create_registration_form(registration_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(
          :info,
          "That's it. Your registration is complete. We've created an initial default waitlist for you."
        )
        |> redirect(to: Routes.billing_payment_plan_path(conn, :edit, payment_plan_id(params)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, payment_plan_id: payment_plan_id(params))
    end
  end

  defp payment_plan_id(params) do
    %{"payment_plan_id" => id} = params
    id
  end
end
