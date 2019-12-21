defmodule LucumaWeb.Waitlists.SettingController do
  use LucumaWeb, :controller

  plug :put_layout, :waitlist

  alias Lucuma.Repo
  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.ConfirmationSmsSetting
  alias Lucuma.Waitlists.AttendanceSmsSetting

  def index(conn, params) do
    %{"waitlist_id" => waitlist_id} = params
    waitlist = Waitlists.get_waitlist!(waitlist_id)
    confirmation_sms_setting = Repo.get_by!(ConfirmationSmsSetting, waitlist_id: waitlist.id)
    attendance_sms_setting = Repo.get_by!(AttendanceSmsSetting, waitlist_id: waitlist.id)

    render(
      conn,
      "index.html",
      waitlist: waitlist,
      confirmation_sms_setting: confirmation_sms_setting,
      confirmation_sms_setting_changeset:
        Waitlists.change_confirmation_sms_setting(confirmation_sms_setting),
      attendance_sms_setting: attendance_sms_setting,
      attendance_sms_setting_changeset:
        Waitlists.change_attendance_sms_setting(attendance_sms_setting)
    )
  end

  def update(conn, %{"confirmation_sms_setting" => sms_setting_params}) do
    sms_setting = Repo.get!(ConfirmationSmsSetting, conn.params["id"])

    case Waitlists.update_confirmation_sms_setting(sms_setting, sms_setting_params) do
      {:ok, sms_setting} ->
        conn
        |> put_flash(:info, "Settings updated successfully.")
        |> redirect(
          to: Routes.waitlists_waitlist_setting_path(conn, :index, sms_setting.waitlist_id)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        # render(conn, "index.html", changeset: changeset, sms_setting: sms_setting)

        waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])
        confirmation_sms_setting = Repo.get_by!(ConfirmationSmsSetting, waitlist_id: waitlist.id)
        attendance_sms_setting = Repo.get_by!(AttendanceSmsSetting, waitlist_id: waitlist.id)

        render(
          conn,
          "index.html",
          waitlist: waitlist,
          confirmation_sms_setting: confirmation_sms_setting,
          confirmation_sms_setting_changeset: changeset,
          attendance_sms_setting: attendance_sms_setting,
          attendance_sms_setting_changeset:
            Waitlists.change_attendance_sms_setting(attendance_sms_setting)
        )
    end
  end

  def update(conn, %{"attendance_sms_setting" => sms_setting_params}) do
    sms_setting = Repo.get!(AttendanceSmsSetting, conn.params["id"])

    case Waitlists.update_attendance_sms_setting(sms_setting, sms_setting_params) do
      {:ok, sms_setting} ->
        conn
        |> put_flash(:info, "Settings updated successfully.")
        |> redirect(
          to: Routes.waitlists_waitlist_setting_path(conn, :index, sms_setting.waitlist_id)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        # render(conn, "index.html", changeset: changeset, sms_setting: sms_setting)

        waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])
        confirmation_sms_setting = Repo.get_by!(ConfirmationSmsSetting, waitlist_id: waitlist.id)
        attendance_sms_setting = Repo.get_by!(AttendanceSmsSetting, waitlist_id: waitlist.id)

        render(
          conn,
          "index.html",
          waitlist: waitlist,
          confirmation_sms_setting: confirmation_sms_setting,
          confirmation_sms_setting_changeset:
            Waitlists.change_confirmation_sms_setting(confirmation_sms_setting),
          attendance_sms_setting: attendance_sms_setting,
          attendance_sms_setting_changeset: changeset
        )
    end
  end
end
