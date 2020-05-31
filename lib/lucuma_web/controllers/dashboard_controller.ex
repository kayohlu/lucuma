defmodule LucumaWeb.DashboardController do
  use LucumaWeb, :controller

  def show(conn, _params) do
    waitlists = Lucuma.Waitlists.business_waitlists(conn.assigns.current_business.id)
    business = conn.assigns.current_business

    stats =
    Enum.reduce(waitlists, %{}, fn waitlist, accum ->
      tasks =
        for function <- [
          :waitlisted,
          :waiting,
          :average_wait_time,
          :average_served_per_hour_for_todays_day
        ] do
      Task.async(Lucuma.Waitlists.Analytics.Today, function, [waitlist.id, business])
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

      Map.put(accum, waitlist, %{
        waitlisted: waitlisted,
        waiting: waiting,
        average_wait_time: average_wait_time,
        average_served_per_hour_for_todays_day: average_served_per_hour_for_todays_day
      })

      end)

    render(conn, "show.html", stats: stats)
  end
end
