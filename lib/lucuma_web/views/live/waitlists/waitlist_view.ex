defmodule LucumaWeb.Live.Waitlists.WaitlistView do
  use Phoenix.LiveView
  import LucumaWeb.Gettext
  require Logger

  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.StandBy
  alias LucumaWeb.Router.Helpers, as: Routes

  def render(assigns) do
    LucumaWeb.Waitlists.WaitlistView.render("show.html", assigns)
  end

  def render("sub_navigation.html", assigns) do
    Phoenix.View.render(
      LucumaWeb.LayoutView,
      "sub_navigation.html",
      Map.put(assigns, :sub_nav_links, sub_nav_links(assigns))
    )
  end

  def sub_nav_links(assigns) do
    links = [
      %{
        path: Routes.waitlists_waitlist_path(assigns.conn, :show, assigns.waitlist.id),
        text: gettext("Waitlist")
      },
      %{
        path: Routes.waitlists_waitlist_analytics_path(assigns.conn, :index, assigns.waitlist.id),
        text: gettext("Analytics")
      }
    ]

    if LucumaWeb.Permissions.permitted_to?(
         assigns.conn,
         LucumaWeb.Waitlists.SettingController,
         :index
       ) do
      links ++
        [
          %{
            path:
              Routes.waitlists_waitlist_setting_path(assigns.conn, :index, assigns.waitlist.id),
            text: gettext("Settings")
          }
        ]
    else
      links
    end
  end

  def mount(params, session, socket) do
    waitlist_id = session["waitlist_id"]
    waitlist = Waitlists.get_waitlist!(waitlist_id)
    stand_bys = Waitlists.get_waitlist_stand_bys(waitlist_id)
    attendance_sms_setting = Waitlists.attendance_sms_setting_for_waitlist(waitlist.id)
    changeset = Waitlists.change_stand_by(%StandBy{})

    Phoenix.PubSub.subscribe(LucumaWeb.PubSub, self(), topic(waitlist_id))

    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      attendance_sms_setting: attendance_sms_setting,
      changeset: changeset,
      show_form: false,
      trial_limit_reached: session["trial_limit_reached"],
      current_company: session["current_company"],
      current_business: session["current_business"]
    ]

    {:ok, assign(socket, assigns)}
  end

  # def handle_event("validate", %{ "stand_by" => stand_by_params}, socket) do
  #   changeset = Waitlists.change_stand_by(%StandBy{}, Map.put(stand_by_params, "waitlist_id", socket.assigns.waitlist.id))
  #               |> Map.put(:action, :insert)

  #   {:noreply, assign(socket, changeset: changeset, show_form: true)}
  # end

  def handle_event("show_form", params, socket) do
    {:noreply, assign(socket, show_form: true)}
  end

  def handle_event("clear_form", params, socket) do
    changeset = Waitlists.change_stand_by(%StandBy{})

    {:noreply, assign(socket, changeset: changeset, show_form: false)}
  end

  def handle_event("save", %{"stand_by" => stand_by_params}, socket) do
    case Waitlists.create_stand_by(
           Map.put(stand_by_params, "waitlist_id", socket.assigns.waitlist.id),
           socket.assigns.current_business,
           socket.assigns.current_company
         ) do
      {:ok, stand_by} ->
        socket = put_flash(socket, :info, "Stand by created successfully.")
        # |> redirect(to: Routes.waitlists_waitlist_path(conn, :show, waitlist))
        waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
        stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)

        assigns = [
          waitlist: waitlist,
          stand_bys: stand_bys,
          # empty changeset so the form is blank.
          changeset: Waitlists.change_stand_by(%StandBy{}),
          party_breakdown: Waitlists.party_size_breakdown(waitlist.id),
          average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id),
          trial_limit_reached: socket.assigns.trial_limit_reached,
          show_form: false
        ]

        socket = assign(socket, assigns)

        Phoenix.PubSub.broadcast_from(LucumaWeb.PubSub, self(), topic(waitlist.id), %{
          event: "save"
        })

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        assigns = [
          changeset: changeset,
          show_form: true
        ]

        socket = assign(socket, assigns)
        {:noreply, socket}
    end
  end

  def handle_event("notify_stand_by", %{"stand-by-id" => stand_by_id} = params, socket) do
    Waitlists.notify_stand_by(socket.assigns.current_business, stand_by_id)

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)

    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      trial_limit_reached: socket.assigns.trial_limit_reached,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    Phoenix.PubSub.broadcast_from(LucumaWeb.PubSub, self(), topic(waitlist.id), %{
      event: "notify_stand_by"
    })

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("mark_as_attended", %{"stand-by-id" => stand_by_id} = params, socket) do
    Waitlists.mark_as_attended(stand_by_id)

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)

    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      trial_limit_reached: socket.assigns.trial_limit_reached,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    Phoenix.PubSub.broadcast_from(LucumaWeb.PubSub, self(), topic(waitlist.id), %{
      event: "mark_as_attended"
    })

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("mark_as_no_show", %{"stand-by-id" => stand_by_id} = params, socket) do
    Waitlists.mark_as_no_show(stand_by_id)

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)

    assigns = [
      waitlist: waitlist,
      stand_bys: stand_bys,
      trial_limit_reached: socket.assigns.trial_limit_reached,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    Phoenix.PubSub.broadcast_from(LucumaWeb.PubSub, self(), topic(waitlist.id), %{
      event: "mark_as_no_show"
    })

    {:noreply, assign(socket, assigns)}
  end

  def terminate(reason, socket) do
    Phoenix.PubSub.unsubscribe(LucumaWeb.PubSub, self(), topic(socket.assigns.waitlist.id))
    Logger.info("#{inspect(__MODULE__)} shutting down with reason #{inspect(reason)}")
  end

  @doc """
  As of writing this the PubSub functionality in this module is only here to
  notify clients that something has changed in the waitlist.
  The changes we expect are:
    1. Some StandyBy has changed.

  AS a result we want to reflect these changes in the clients.
  """
  def handle_info(message, socket) do
    Logger.info("Receiving message from PubSub")

    waitlist = Waitlists.get_waitlist!(socket.assigns.waitlist.id)
    stand_bys = Waitlists.get_waitlist_stand_bys(socket.assigns.waitlist.id)

    assigns = [
      stand_bys: stand_bys,
      trial_limit_reached: socket.assigns.trial_limit_reached,
      average_wait_time: Waitlists.calculate_average_wait_time(waitlist.id)
    ]

    {:noreply, assign(socket, assigns)}
  end

  defp topic(waitlist_id) do
    "waitlist_#{waitlist_id}"
  end
end
