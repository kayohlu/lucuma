defmodule HoldUpWeb.Waitlists.SmsSettingController do
  use HoldUpWeb, :controller

  plug :put_layout, :waitlist

  alias HoldUp.Repo
  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.SmsSetting

  def index(conn, _params) do
    waitlist = Waitlists.get_waitlist!(1)

    sms_setting = Repo.get_by!(SmsSetting, waitlist_id: waitlist.id)
    changeset = Waitlists.change_sms_setting(sms_setting)
    render(conn, "index.html", changeset: changeset, sms_setting: sms_setting)
  end

  def update(conn, %{"sms_setting" => sms_setting_params}) do
    waitlist = Waitlists.get_waitlist!(1)
    sms_setting = Repo.get_by!(SmsSetting, waitlist_id: waitlist.id)

    case Waitlists.update_sms_setting(sms_setting, sms_setting_params) do
      {:ok, sms_setting} ->
        conn
        |> put_flash(:info, "SMS settings updated successfully.")
        |> redirect(to: Routes.waitlists_waitlist_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", changeset: changeset, sms_setting: sms_setting)
    end
  end
end