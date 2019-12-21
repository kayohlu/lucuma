defmodule LucumaWeb.Waitlists.AnalyticsController do
  use LucumaWeb, :controller

  plug :put_layout, :waitlist

  alias Lucuma.Repo
  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.Analytics
  alias Lucuma.Waitlists.StandBy

  def index(conn, params) do
    %{"waitlist_id" => waitlist_id} = params
    waitlist = Waitlists.get_waitlist!(waitlist_id)

    if Repo.exists?(StandBy) do
      render(
        conn,
        "index.html",
        waitlist: waitlist,
        has_stand_bys: true,
        total_waitlisted: Analytics.total_waitlisted(waitlist.id),
        unique_customer_count: Analytics.unique_customer_count(waitlist.id),
        served_customer_count: Analytics.served_customer_count(waitlist.id),
        served_percentage: Analytics.served_percentage(waitlist.id),
        no_show_percentage: Analytics.no_show_percentage(waitlist.id),
        cancellation_percentage: Analytics.cancellation_percentage(waitlist.id),
        waitlisted_per_date: Analytics.waitlisted_per_date(waitlist.id),
        served_per_date: Analytics.served_per_date(waitlist_id),
        no_show_per_date: Analytics.no_show_per_date(waitlist_id),
        cancellation_per_date: Analytics.cancellation_per_date(waitlist_id),
        average_wait_time_per_date: Analytics.average_wait_time_per_date(waitlist.id),
        average_served_per_day: Analytics.average_served_per_day(waitlist.id),
        average_served_per_hour: Analytics.average_served_per_hour(waitlist.id),
        average_served_per_hour_per_day: Analytics.average_served_per_hour_per_day(waitlist.id)
      )
    else
      render(
        conn,
        "index.html",
        waitlist: waitlist,
        has_stand_bys: false
      )
    end
  end
end
