defmodule Lucuma.Waitlists.Analytics.Today do
  @moduledoc """
  """
  import Ecto.Query

  alias Lucuma.Repo
  alias Lucuma.Waitlists.StandBy

  def waitlisted(waitlist_id) do
    {:ok, start_of_today} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])

    Repo.one(
      from s in StandBy,
        where: s.waitlist_id == ^waitlist_id and s.inserted_at >= ^start_of_today,
        select: count(s.id)
    )
  end

  def waiting(waitlist_id) do
    {:ok, start_of_today} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])

    Repo.one(
      from s in StandBy,
        where:
          is_nil(s.notified_at) and
            is_nil(s.no_show_at) and
            is_nil(s.attended_at) and
            is_nil(s.cancelled_at) and
            s.waitlist_id == ^waitlist_id and
            s.inserted_at >= ^start_of_today,
        select: count(s.id)
    )
  end

  def average_wait_time(waitlist_id) do
    {:ok, start_of_today} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])

    db_result =
      Repo.one(
        from s in StandBy,
          where:
            not is_nil(s.notified_at) and s.waitlist_id == ^waitlist_id and
              s.inserted_at >= ^start_of_today,
          select: avg(s.notified_at - s.inserted_at)
      )

    case db_result do
      %Postgrex.Interval{days: _d, months: _m, secs: seconds} -> round(seconds / 60)
      _ -> 0
    end
  end

  @moduledoc """
  Returns the average amount of people served grouped by hour.
  The average amount of people served per hour every Monday, Tuesday, etc..
  """
  def average_served_per_hour_for_todays_day(waitlist_id) do
    {:ok, start_of_today} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])
    todays_day = Date.utc_today() |> Date.day_of_week()

    grouped_by_day_hour_date_query =
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.attended_at) and
            fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at) == ^todays_day,
        group_by: [
          fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at),
          fragment("EXTRACT(HOUR FROM ?)", s.inserted_at),
          fragment("?::date::timestamp", s.inserted_at)
        ],

        # https://stackoverflow.com/questions/42045295/ecto-queryerror-on-a-subquery
        # Write explanation.
        select: %{
          day: fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at),
          hour: fragment("EXTRACT(HOUR FROM ?)", s.inserted_at),
          date: fragment("?::date::timestamp", s.inserted_at),
          day_hour_date_count: fragment("?::float", count(s.id))
        }

    Repo.all(
      from s in subquery(grouped_by_day_hour_date_query),
        group_by: [s.day, s.hour],
        order_by: [s.day, s.hour],
        select: [s.day, s.hour, avg(s.day_hour_date_count)]
    )
  end
end
