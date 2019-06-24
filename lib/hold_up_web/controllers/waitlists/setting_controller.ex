defmodule HoldUpWeb.Waitlists.SettingController do
  use HoldUpWeb, :controller

  plug :put_layout, :waitlist

  alias HoldUp.Repo
  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.ConfirmationSmsSetting
  alias HoldUp.Waitlists.AttendanceSmsSetting

  def index(conn, params) do
    render(
      conn,
      "index.html",
      settings_for_page(params)
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
        render(conn, "index.html", changeset: changeset, sms_setting: sms_setting)
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
        render(conn, "index.html", changeset: changeset, sms_setting: sms_setting)
    end
  end

  def settings_for_page(params) do
    %{"waitlist_id" => waitlist_id} = params
    waitlist = Waitlists.get_waitlist!(waitlist_id)
    confirmation_sms_setting = Repo.get_by!(ConfirmationSmsSetting, waitlist_id: waitlist.id)
    attendance_sms_setting = Repo.get_by!(AttendanceSmsSetting, waitlist_id: waitlist.id)

    [
      waitlist: waitlist,
      confirmation_sms_setting: confirmation_sms_setting,
      confirmation_sms_setting_changeset:
        Waitlists.change_confirmation_sms_setting(confirmation_sms_setting),
      attendance_sms_setting: attendance_sms_setting,
      attendance_sms_setting_changeset:
        Waitlists.change_attendance_sms_setting(attendance_sms_setting)
    ]
  end
end
