defmodule HoldUpWeb.InvitationController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts
  alias HoldUp.Accounts.User

  plug :put_layout, {HoldUpWeb.LayoutView, :only_form} when action in [:show, :update]

  def new(conn, _params) do
    changeset = Accounts.change_invitation(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => invitation_params}) do
    case Accounts.create_invited_user(
           conn.assigns.current_user,
           conn.assigns.current_company,
           conn.assigns.current_business,
           invitation_params
         ) do
      {:ok, invited_user} ->
        HoldUpWeb.Emails.Email.invitation_email(invited_user) |> HoldUpWeb.Mailer.deliver_now()

        conn
        |> put_flash(:info, "Invitation created successfully.")
        |> redirect(to: Routes.settings_staff_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user_by_invitation(id)

    if user do
      if Accounts.user_invitation_expired(user) do
        redirect(conn,
          to: Routes.invitations_invitation_expiry_path(conn, :show, user.invitation_token)
        )
      else
        case user.invitation_accepted_at do
          nil ->
            changeset = Accounts.change_user(user)
            render(conn, "show.html", changeset: changeset, user: user)

          _ ->
            conn
            |> put_status(:not_found)
            |> put_view(HoldUpWeb.ErrorView)
            |> put_layout({HoldUpWeb.LayoutView, :app})
            |> render(:"404")
            |> halt()
        end
      end
    else
      conn
      |> put_status(:not_found)
      |> put_view(HoldUpWeb.ErrorView)
      |> put_layout({HoldUpWeb.LayoutView, :app})
      |> render(:"404")
      |> halt()
    end
  end

  def update(conn, %{"id" => id, "invitation" => invited_user_params}) do
    invited_user = Accounts.get_user_by_invitation(id)

    case Accounts.accept_user_invite(invited_user, invited_user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Invitation accepted successfully.")
        |> HoldUpWeb.Plugs.Authentication.sign_in_user(user)
        |> redirect(to: Routes.dashboard_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", changeset: changeset, user: invited_user)
    end
  end
end
