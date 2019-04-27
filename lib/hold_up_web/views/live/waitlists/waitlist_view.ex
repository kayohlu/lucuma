defmodule HoldUpWeb.Live.Waitlists.WaitlistView do
  use Phoenix.LiveView

  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.StandBy

  def render(assigns) do
    HoldUpWeb.Waitlists.WaitlistView.render("show.html", assigns)
  end

  def mount(session, socket) do
    waitlist = Waitlists.get_waitlist!(session.waitlist_id)
    stand_bys = Waitlists.get_waitlist_stand_bys(session.waitlist_id)
    attendance_sms_setting = Waitlists.attendance_sms_setting_for_waitlist(waitlist.id)
    party_breakdown = Waitlists.party_size_breakdown(waitlist.id)
    average_wait_time = Waitlists.calculate_average_wait_time(waitlist.id)
    changeset = Waitlists.change_stand_by(%StandBy{})

    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      attendance_sms_setting: attendance_sms_setting,
      party_breakdown: party_breakdown,
      average_wait_time: average_wait_time,
      changeset: changeset,
      show_modal: false
    ]

    {:ok, assign(socket, assigns)}
  end

  # def handle_event("validate", %{ "stand_by" => stand_by_params}, socket) do
  #   changeset = Waitlists.change_stand_by(%StandBy{}, Map.put(stand_by_params, "waitlist_id", socket.assigns.waitlist.id))
  #               |> Map.put(:action, :insert)

  #   {:noreply, assign(socket, changeset: changeset, show_modal: true)}
  # end

   def handle_event("show_modal", "", socket) do
    IO.inspect {:showmodal}
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("clear_form", %{ "stand_by" => stand_by_params}, socket) do
    changeset = Waitlists.change_stand_by(%StandBy{})

    {:noreply, assign(socket, changeset: changeset, show_modal: false)}
  end

  def handle_event("save", %{ "stand_by" => stand_by_params}, socket) do
    case Waitlists.create_stand_by(Map.put(stand_by_params, "waitlist_id", socket.assigns.waitlist.id)) do
      {:ok, stand_by} ->
        socket = put_flash(socket, :info, "Stand by created successfully.")
        # |> redirect(to: Routes.waitlists_waitlist_path(conn, :show, waitlist))
        waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
        stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)
        assigns = [
          waitlist: waitlist,
          stand_bys: stand_bys,
          changeset: Waitlists.change_stand_by(%StandBy{}), # empty changeset so the form is blank.
          party_breakdown: Waitlists.party_size_breakdown(waitlist.id),
          average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id),
          show_modal: false
        ]

        IO.inspect {:ok, assigns}

        socket = assign(socket, assigns)

        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        assigns = [
          changeset: changeset,
          show_modal: true
        ]

        socket = assign(socket, assigns)
        {:noreply, socket}
    end
  end

  def handle_event("notify_stand_by", stand_by_id, socket) do
    Waitlists.notify_stand_by(stand_by_id)

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)
    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("mark_as_attended", stand_by_id, socket) do
    Waitlists.mark_as_attended(stand_by_id)

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)
    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("mark_as_no_show", stand_by_id, socket) do
    Waitlists.mark_as_no_show(stand_by_id)

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)
    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    {:noreply, assign(socket, assigns)}
  end
end
