defmodule LucumaWeb.DashboardController do
  use LucumaWeb, :controller

  def show(conn, _params) do
    waitlist = Lucuma.Waitlists.get_business_waitlist(conn.assigns.current_business.id)

    tasks =
      for function <- [
            :waitlisted,
            :waiting,
            :average_wait_time,
            :average_served_per_hour_for_todays_day
          ] do
        Task.async(Lucuma.Waitlists.Analytics.Today, function, [waitlist.id])
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

    IO.puts("==========================================================")

    IO.inspect(
      waitlisted: waitlisted,
      waiting: waiting,
      average_wait_time: average_wait_time,
      average_served_per_hour_for_todays_day: average_served_per_hour_for_todays_day
    )

    render(conn, "show.html",
      waitlisted: waitlisted,
      waiting: waiting,
      average_wait_time: average_wait_time,
      average_served_per_hour_for_todays_day: average_served_per_hour_for_todays_day
    )
  end
end
