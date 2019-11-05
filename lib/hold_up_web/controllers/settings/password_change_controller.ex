defmodule HoldUpWeb.Settings.PasswordChangeController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts

  plug :put_layout, :settings

  def update(conn, params) do
    case Accounts.update_user_password(conn.assigns.current_user, params["user"]) do
      {:ok, updated_user} ->
        conn
        |> put_flash(:info, "Password changed successfully.")
        |> redirect(to: Routes.settings_profile_path(conn, :show))

      {:error, password_changeset} ->
        profile_changeset = HoldUp.Accounts.change_user_profile(conn.assigns.current_user)

        render(conn, HoldUpWeb.Settings.ProfileView, :show,
          profile_changeset: profile_changeset,
          password_changeset: password_changeset
        )
    end
  end
end
