defmodule Lucuma.WaitlistsTests.TodayTest do
  use Lucuma.DataCase, async: true
  use Timex

  import Lucuma.Factory

  alias Lucuma.Waitlists.Analytics.Today
  alias Lucuma.Waitlists.StandBy

  describe "waitlisted/1" do
    test "returns the number of people waitlisted today" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      {:ok, today_mid_day} = NaiveDateTime.new(Date.utc_today(), ~T[12:00:00])

      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: today_mid_day)

      {:ok, yesterday_mid_day} =
        Date.utc_today()
        |> Timex.shift(days: -1)
        |> NaiveDateTime.new(~T[12:00:00])

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: yesterday_mid_day
      )

      assert Today.waitlisted(waitlist.id, business) == 1
    end
  end

  describe "waiting/1" do
    test "returns the number of people waitlisted today" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      {:ok, today_mid_day} = NaiveDateTime.new(Date.utc_today(), ~T[12:00:00])

      {:ok, yesterday_mid_day} =
        Date.utc_today()
        |> Timex.shift(days: -1)
        |> NaiveDateTime.new(~T[12:00:00])

      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: today_mid_day)

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        notified_at: today_mid_day
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        no_show_at: today_mid_day
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        attended_at: today_mid_day
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        cancelled_at: today_mid_day
      )

      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: yesterday_mid_day)

      assert Today.waiting(waitlist.id, business) == 1
    end
  end

  describe "#average_wait_time/1" do
    test "returns the correct average wait time for customers in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      {:ok, today_mid_day} =
        Date.utc_today()
        |> NaiveDateTime.new(~T[12:00:00])

      today_mid_day = DateTime.from_naive!(today_mid_day, "Etc/UTC")

      {:ok, yesterday_mid_day} =
        Date.utc_today()
        |> Timex.shift(days: -1)
        |> NaiveDateTime.new(~T[12:00:00])

      yesterday_mid_day = DateTime.from_naive!(yesterday_mid_day, "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        notified_at: DateTime.add(today_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        notified_at: DateTime.add(today_mid_day, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        notified_at: DateTime.add(today_mid_day, 180, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: yesterday_mid_day,
        notified_at: DateTime.add(yesterday_mid_day, 60, :second)
      )

      # the 2 refers to 2 minutes
      assert Today.average_wait_time(waitlist.id, business) == 2
    end
  end

  describe "#average_served_per_hour/1" do
    test "returns the correct average number of customers served per hour in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      {:ok, today_mid_day} =
        Date.utc_today()
        |> NaiveDateTime.new(~T[12:00:00])

      today_mid_day = DateTime.from_naive!(today_mid_day, "Etc/UTC")

      {:ok, yesterday_mid_day} =
        Date.utc_today()
        |> Timex.shift(days: -1)
        |> NaiveDateTime.new(~T[12:00:00])

      yesterday_mid_day = DateTime.from_naive!(yesterday_mid_day, "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        attended_at: DateTime.add(today_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        attended_at: DateTime.add(today_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        attended_at: DateTime.add(today_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: yesterday_mid_day,
        attended_at: DateTime.add(yesterday_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: yesterday_mid_day,
        attended_at: DateTime.add(yesterday_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: yesterday_mid_day,
        attended_at: DateTime.add(yesterday_mid_day, 60, :second)
      )

      # 1 refers to the integer value of monday in the week.
      # 2 is the average count value.
      # [day int value, hour, avg count value]
      expected_results = [
        [Date.utc_today() |> Date.day_of_week(), 12, 3]
      ]

      assert Today.average_served_per_hour_for_todays_day(waitlist.id, business) ==
               expected_results
    end
  end
end
