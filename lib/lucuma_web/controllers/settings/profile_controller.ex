defmodule LucumaWeb.Settings.ProfileController do
  use LucumaWeb, :controller

  alias Lucuma.Accounts

  plug :put_layout, :settings

  def show(conn, params) do
    profile_changeset = Lucuma.Accounts.change_user_profile(conn.assigns.current_user)
    password_changeset = Lucuma.Accounts.change_user_password(conn.assigns.current_user)

    render(conn, "show.html",
      profile_changeset: profile_changeset,
      password_changeset: password_changeset
    )
  end

  def update(conn, params) do
    case Accounts.update_user_profile(conn.assigns.current_user, params["user"]) do
      {:ok, updated_user} ->
        conn
        |> put_flash(:info, "Profile update successfully.")
        |> redirect(to: Routes.settings_profile_path(conn, :show))

      {:error, profile_changeset} ->
        password_changeset = Lucuma.Accounts.change_user_password(conn.assigns.current_user)

        render(conn, "show.html",
          profile_changeset: profile_changeset,
          password_changeset: password_changeset
        )
    end
  end
end
