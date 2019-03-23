defmodule HoldUpWeb.Waitlists.WaitlistController do
  use HoldUpWeb, :controller

  plug :put_layout, :waitlist

  alias HoldUp.Waitlists

  def index(conn, _params) do
    waitlist = Waitlists.get_business_waitlist(conn.assigns.current_business.id)
    redirect(conn, to: Routes.waitlists_waitlist_path(conn, :show, waitlist.id))
  end

  def show(conn, %{"id" => id}) do
    waitlist = Waitlists.get_waitlist!(id)
    attendance_sms_setting = Waitlists.attendance_sms_setting_for_waitlist(waitlist.id)
    party_breakdown = Waitlists.party_size_breakdown(waitlist.id)
    average_wait_time = Waitlists.calculate_average_wait_time(waitlist.id)
    render(conn, "show.html", waitlist: waitlist, party_breakdown: party_breakdown, average_wait_time: average_wait_time, attendance_sms_setting: attendance_sms_setting)
  end
end