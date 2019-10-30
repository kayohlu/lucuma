defmodule HoldUpWeb.Settings.ProfileController do
  use HoldUpWeb, :controller

  plug :put_layout, :settings

  def show(conn, params) do
    profile_changeset = HoldUp.Accounts.change_user_profile(conn.assigns.current_user)
    password_changeset = HoldUp.Accounts.change_user_password(conn.assigns.current_user)

    render(conn, "show.html",
      profile_changeset: profile_changeset,
      password_changeset: password_changeset
    )
  end
end
