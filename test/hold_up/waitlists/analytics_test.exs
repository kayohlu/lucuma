defmodule HoldUp.WaitlistsTests.AnalyticsTest do
  use HoldUp.DataCase, async: true

  import HoldUp.Factory

  alias HoldUp.Waitlists
  alias HoldUp.Waitlists.Analytics
  alias HoldUp.Accounts

  describe "#total_waitlisted/1" do
    test "returns the correct amount of customers added to the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      assert Analytics.total_waitlisted(waitlist.id) == 0
    end
  end

  describe "#unique_customer_count/1" do
    test "returns the correct amount of customers added to the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, contact_phone_number: "+353851761516")
      insert(:stand_by, waitlist_id: waitlist.id, contact_phone_number: "+353851761516")
      insert(:stand_by, waitlist_id: waitlist.id, contact_phone_number: "+353851761511")

      assert Analytics.unique_customer_count(waitlist.id) == 2
    end
  end

  describe "#served_percentage/1" do
    test "returns the correct percentage of total customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, attended_at: NaiveDateTime.utc_now)
      insert(:stand_by, waitlist_id: waitlist.id)

      assert Analytics.served_percentage(waitlist.id) == 50.0
    end
  end

  describe "#no_show_percentage/1" do
    test "returns the correct percentage of total customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, no_show_at: NaiveDateTime.utc_now)
      insert(:stand_by, waitlist_id: waitlist.id)

      assert Analytics.no_show_percentage(waitlist.id) == 50.0
    end
  end

  describe "#cancellation_percentage/1" do
    test "returns the correct percentage of total customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, cancelled_at: NaiveDateTime.utc_now)
      insert(:stand_by, waitlist_id: waitlist.id)

      assert Analytics.cancellation_percentage(waitlist.id) == 50.0
    end
  end

  describe "#waitlisted_per_day/1" do
    test "returns the correct percentage of total customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: DateTime.add(DateTime.utc_now(), -(3600 * 24), :second))
      insert(:stand_by, waitlist_id: waitlist.id)

      yesterday_date = DateTime.utc_now()
                       |> DateTime.add(-(3600 * 24), :second)
                       |> DateTime.to_date

      expected_results = [
        [yesterday_date, 1],
        [DateTime.to_date(DateTime.utc_now()), 1]
      ]

      assert Analytics.waitlisted_per_day(waitlist.id) == expected_results
    end
  end

  describe "#average_wait_time_per_day/1" do
    test "returns the correct average wait time for customers per day in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      now_1_day_ago = DateTime.utc_now
                      |> DateTime.add(-(3600 * 24), :second)

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: now_1_day_ago,
        notified_at: DateTime.add(now_1_day_ago, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: now_1_day_ago,
        notified_at: DateTime.add(now_1_day_ago, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: now_1_day_ago,
        notified_at: DateTime.add(now_1_day_ago, 180, :second)
      )

      an_hour_ago = DateTime.utc_now
                      |> DateTime.add(-(3600 * 1), :second)

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: an_hour_ago,
        notified_at: DateTime.add(an_hour_ago, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: an_hour_ago,
        notified_at: DateTime.add(an_hour_ago, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: an_hour_ago,
        notified_at: DateTime.add(an_hour_ago, 180, :second)
      )

      # the 2 refers to 2 minutes
      expected_results = [
        [now_1_day_ago |> DateTime.to_date, 2],
        [DateTime.to_date(DateTime.utc_now()), 2]
      ]

      assert Analytics.average_wait_time_per_day(waitlist.id) == expected_results
    end
  end
end
