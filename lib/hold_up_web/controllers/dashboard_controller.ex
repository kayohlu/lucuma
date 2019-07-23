defmodule HoldUpWeb.DashboardController do
  use HoldUpWeb, :controller

  def show(conn, _params) do
    waitlist = HoldUp.Waitlists.get_business_waitlist(conn.assigns.current_business.id)

    tasks =
      for function <- [
            :waitlisted,
            :waiting,
            :average_wait_time,
            :average_served_per_hour_for_todays_day
          ] do
        Task.async(HoldUp.Waitlists.Analytics.Today, function, [waitlist.id])
      end

    [
      waitlisted,
      waiting,
      average_wait_time,
      average_served_per_hour_for_todays_day
    ] =
      Task.yield_many(tasks, 5000)
      |> Enum.map(fn {task, result_tuple} -> result_tuple || Task.shutdown(task, :brutal_kill) end)
      |> Enum.map(fn {:ok, result} -> result end)

    render(conn, "show.html",
      waitlisted: waitlisted,
      waiting: waiting,
      average_wait_time: average_wait_time,
      average_served_per_hour_for_todays_day: average_served_per_hour_for_todays_day
    )
  end

  defp tasks do
  end
end
