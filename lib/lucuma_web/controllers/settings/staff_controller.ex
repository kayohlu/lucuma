defmodule LucumaWeb.Settings.StaffController do
  use LucumaWeb, :controller

  alias Lucuma.Accounts

  plug :put_layout, :settings

  def show(conn, params) do
    staff = Accounts.list_staff(conn.assigns.current_business)
    render(conn, "show.html", staff: staff)
  end

  def delete(conn, %{"id" => user_id}) do
    staff = Accounts.list_staff(conn.assigns.current_business)

    case Accounts.delete_staff_memeber(user_id) do
      {:ok, staff_user} ->
        redirect(conn, to: Routes.settings_staff_path(conn, :show))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Could not delete staff member, please contact support for help.")
        |> Routes.settings_staff_path(conn, :show)
    end
  end
end
