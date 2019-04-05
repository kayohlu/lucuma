defmodule HoldUp.Waitlists.Analytics do
  import Ecto.Query

  alias HoldUp.Repo
  alias HoldUp.Waitlists.StandBy

  def total_waitlisted(waitlist_id) do
    Repo.one(from s in StandBy, where: s.waitlist_id == ^waitlist_id, select: count(s.id))
  end

  def unique_customer_count(waitlist_id) do
    Repo.one(from s in StandBy, where: s.waitlist_id == ^waitlist_id, select: count(s.contact_phone_number, :distinct))
  end

  def served_percentage(waitlist_id) do
    count = Repo.one(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id
        and not is_nil(s.attended_at),
      select: count(s.id)
    )

    total_count = Repo.one(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id,
      select: count(s.id)
    )

    (count / total_count) * (100 / 1)
  end

  def no_show_percentage(waitlist_id) do
    count = Repo.one(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id
        and not is_nil(s.no_show_at),
      select: count(s.id)
    )

    total_count = Repo.one(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id,
      select: count(s.id)
    )

    (count / total_count) * (100 / 1)
  end

  def cancellation_percentage(waitlist_id) do
    count = Repo.one(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id
        and not is_nil(s.cancelled_at),
      select: count(s.id)
    )

    total_count = Repo.one(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id,
      select: count(s.id)
    )

    (count / total_count) * (100 / 1)
  end

  def waitlisted_per_day(waitlist_id) do
    Repo.all(
      from s in StandBy,
      where:
        s.waitlist_id == ^waitlist_id,
      group_by: fragment("?::date", s.inserted_at), # Use a fragment to write some raw sql to convert timestamp to date.
      select: [fragment("?::date", s.inserted_at), count(s.id)]
    )
  end

  def average_wait_time_per_day(waitlist_id) do
    db_result =
      Repo.all(
        from s in StandBy,
          where:
            not is_nil(s.notified_at)
            and s.waitlist_id == ^waitlist_id,
          group_by: fragment("?::date", s.inserted_at), # Use a fragment to write some raw sql to convert timestamp to date.
          select: [fragment("?::date", s.inserted_at), avg(s.notified_at - s.inserted_at)]
      )

    handle_average = fn (db_result) ->
      case db_result do
        %Postgrex.Interval{days: _d, months: _m, secs: seconds} -> round(seconds / 60)
        _ -> 0
      end
    end

    Enum.map(db_result, fn [date, average] -> [date, handle_average.(average)] end)
  end
end