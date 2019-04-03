defmodule HoldUpWeb.Live.Waitlists.WaitlistView do
  use Phoenix.LiveView

  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.StandBy

  def render(assigns) do
    HoldUpWeb.Waitlists.WaitlistView.render("show.html", assigns)
  end

  def mount(session, socket) do
    waitlist = Waitlists.get_waitlist!(session.waitlist_id)
    attendance_sms_setting = Waitlists.attendance_sms_setting_for_waitlist(waitlist.id)
    party_breakdown = Waitlists.party_size_breakdown(waitlist.id)
    average_wait_time = Waitlists.calculate_average_wait_time(waitlist.id)
    changeset = Waitlists.change_stand_by(%StandBy{})

    assigns = [
      waitlist: waitlist,
      attendance_sms_setting: attendance_sms_setting,
      party_breakdown: party_breakdown,
      average_wait_time: average_wait_time,
      changeset: changeset,
      show_modal: false
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("validate", %{ "stand_by" => stand_by_params}, socket) do
    changeset = Waitlists.change_stand_by(%StandBy{}, Map.put(stand_by_params, "waitlist_id", socket.assigns.waitlist.id))
                |> Map.put(:action, :insert)

    IO.inspect changeset

    assigns = [
      changeset: changeset,
      show_modal: true
    ]

    socket = assign(socket, assigns)

    IO.inspect socket

    {:noreply, socket}
  end
end
