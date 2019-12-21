defmodule LucumaWeb.RegistrationController do
  use LucumaWeb, :controller

  alias Lucuma.Registrations
  alias Lucuma.Registrations.RegistrationForm

  plug :put_layout, {LucumaWeb.LayoutView, :only_form} when action in [:new, :create]

  @type schema :: Ecto.Schema.t()
  @type conn :: Plug.Conn.t()
  @type params :: Map.t()

  @spec new(conn, params) :: conn
  def new(conn, params) do
    changeset = Registrations.change_registration_form(%RegistrationForm{})

    render(conn, "new.html",
      changeset: changeset,
      payment_plan_id: payment_plan_id(params),
      action: form_post_action(conn, payment_plan_id(params))
    )
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
          "That's it. Your registration is complete. We've created an initial default waitlist for you. You can add up to 100 people to your waitlist."
        )
        |> redirect(to: registration_complete_redirect_path(conn, payment_plan_id(params)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          payment_plan_id: payment_plan_id(params),
          action: form_post_action(conn, payment_plan_id(params))
        )
    end
  end

  defp payment_plan_id(%{"payment_plan_id" => id}) do
    id
  end

  # iex(6)> %{} = %{hello: "asd"}
  # %{hello: "asd"}
  # Seems to match any map, but because the method definition above is first
  # it matches a map with the payment_plan_id key in it.
  defp payment_plan_id(%{}) do
    nil
  end

  def form_post_action(conn, nil) do
    Routes.registration_path(conn, :create)
  end

  def form_post_action(conn, payment_plan_id) do
    Routes.registration_path(conn, :create, payment_plan_id: payment_plan_id)
  end

  def registration_complete_redirect_path(conn, nil) do
    Routes.dashboard_path(conn, :show)
  end

  def registration_complete_redirect_path(conn, payment_plan_id) do
    Routes.billing_payment_plan_path(conn, :edit, payment_plan_id)
  end
end
