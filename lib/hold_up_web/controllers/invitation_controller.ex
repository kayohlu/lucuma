defmodule HoldUpWeb.InvitationController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts
  alias HoldUp.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_invitation(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => invitation_params}) do
    params =
      invitation_params
      |> Map.put("company_id", conn.assigns.current_company.id)
      |> Map.put("invited_by_id", conn.assigns.current_user.id)

    case Accounts.create_invited_user(params) do
      {:ok, invited_user} ->
        HoldUpWeb.Emails.Email.invitation_email(invited_user) |> HoldUpWeb.Mailer.deliver_now()

        conn
        |> put_flash(:info, "Invitation created successfully.")
        |> redirect(to: Routes.settings_stagg_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   invitation = Accounts.get_invitation!(id)
  #   render(conn, "show.html", invitation: invitation)
  # end

  # def edit(conn, %{"id" => id}) do
  #   invitation = Accounts.get_invitation!(id)
  #   changeset = Accounts.change_invitation(invitation)
  #   render(conn, "edit.html", invitation: invitation, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "invitation" => invitation_params}) do
  #   invitation = Accounts.get_invitation!(id)

  #   case Accounts.update_invitation(invitation, invitation_params) do
  #     {:ok, invitation} ->
  #       conn
  #       |> put_flash(:info, "Invitation updated successfully.")
  #       |> redirect(to: Routes.invitation_path(conn, :show, invitation))

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", invitation: invitation, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   invitation = Accounts.get_invitation!(id)
  #   {:ok, _invitation} = Accounts.delete_invitation(invitation)

  #   conn
  #   |> put_flash(:info, "Invitation deleted successfully.")
  #   |> redirect(to: Routes.invitation_path(conn, :index))
  # end
end
