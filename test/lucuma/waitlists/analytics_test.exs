defmodule Lucuma.WaitlistsTests.AnalyticsTest do
  use Lucuma.DataCase, async: true

  import Lucuma.Factory

  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.Analytics
  alias Lucuma.Accounts

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

      insert(:stand_by, waitlist_id: waitlist.id, attended_at: NaiveDateTime.utc_now())
      insert(:stand_by, waitlist_id: waitlist.id)

      assert Analytics.served_percentage(waitlist.id) == 50.0
    end
  end

  describe "#no_show_percentage/1" do
    test "returns the correct percentage of total customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, no_show_at: NaiveDateTime.utc_now())
      insert(:stand_by, waitlist_id: waitlist.id)

      assert Analytics.no_show_percentage(waitlist.id) == 50.0
    end
  end

  describe "#cancellation_percentage/1" do
    test "returns the correct percentage of total customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      insert(:stand_by, waitlist_id: waitlist.id, cancelled_at: NaiveDateTime.utc_now())
      insert(:stand_by, waitlist_id: waitlist.id)

      assert Analytics.cancellation_percentage(waitlist.id) == 50.0
    end
  end

  describe "#waitlisted_per_date/1" do
    test "returns the correct number of customers added to the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      # now_1_day_ago = DateTime.utc_now |> DateTime.add(-(3600 * 24), :second)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 00:00:00.000000], "Etc/UTC")
      tuesday_05_march_19 = DateTime.from_naive!(~N[2018-03-05 00:00:00.000000], "Etc/UTC")

      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: monday_04_march_19)
      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: tuesday_05_march_19)

      # yesterday_date = DateTime.utc_now()
      #                  |> DateTime.add(-(3600 * 24), :second)
      #                  |> DateTime.to_date

      expected_results = [
        [monday_04_march_19 |> DateTime.to_naive(), 1],
        [tuesday_05_march_19 |> DateTime.to_naive(), 1]
      ]

      assert Analytics.waitlisted_per_date(waitlist.id) == expected_results
    end
  end

  describe "#served_per_date/1" do
    test "returns the correct number customers served in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      # now_1_day_ago = DateTime.utc_now |> DateTime.add(-(3600 * 24), :second)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 00:00:00.000000], "Etc/UTC")
      tuesday_05_march_19 = DateTime.from_naive!(~N[2018-03-05 00:00:00.000000], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: monday_04_march_19
      )

      insert(:stand_by, waitlist_id: waitlist.id, inserted_at: tuesday_05_march_19)

      yesterday_date =
        DateTime.utc_now()
        |> DateTime.add(-(3600 * 24), :second)
        |> DateTime.to_date()

      expected_results = [
        [monday_04_march_19 |> DateTime.to_naive(), 1]
      ]

      assert Analytics.served_per_date(waitlist.id) == expected_results
    end
  end

  describe "#now_show_per_date/1" do
    test "returns the correct number customer no shows in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      # now_1_day_ago = DateTime.utc_now |> DateTime.add(-(3600 * 24), :second)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 00:00:00.000000], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        no_show_at: monday_04_march_19
      )

      insert(:stand_by, waitlist_id: waitlist.id)

      # yesterday_date = DateTime.utc_now()
      #                  |> DateTime.add(-(3600 * 24), :second)
      #                  |> DateTime.to_date

      expected_results = [
        [monday_04_march_19 |> DateTime.to_naive(), 1]
      ]

      assert Analytics.no_show_per_date(waitlist.id) == expected_results
    end
  end

  describe "#cancellation_per_date/1" do
    test "returns the correct number of customers cancelled in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      # now_1_day_ago = DateTime.utc_now |> DateTime.add(-(3600 * 24), :second)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 00:00:00.000000], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        cancelled_at: monday_04_march_19
      )

      insert(:stand_by, waitlist_id: waitlist.id)

      # yesterday_date = DateTime.utc_now()
      #                  |> DateTime.add(-(3600 * 24), :second)
      #                  |> DateTime.to_date

      expected_results = [
        [monday_04_march_19 |> DateTime.to_naive(), 1]
      ]

      assert Analytics.cancellation_per_date(waitlist.id) == expected_results
    end
  end

  describe "#average_served_per_day/1" do
    test "returns the correct average number of customers served per day of the week in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 12:00:00], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      monday_11_march_19 = DateTime.from_naive!(~N[2018-03-11 12:00:00], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      # 1 refers to the integer value of monday in the week.
      # 2 is the average count value.
      expected_results = [
        [7, 3]
      ]

      assert Analytics.average_served_per_day(waitlist.id) == expected_results
    end
  end

  describe "#average_served_per_hour/1" do
    test "returns the correct average number of customers served per day of the week in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 12:00:00], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      monday_11_march_19 = DateTime.from_naive!(~N[2018-03-11 12:00:00], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      # 1 refers to the integer value of monday in the week.
      # 2 is the average count value.
      expected_results = [
        [12, 3]
      ]

      assert Analytics.average_served_per_hour(waitlist.id) == expected_results
    end
  end

  describe "#average_served_per_hour_per_day/1" do
    test "returns the correct average number of customers served per hour per day of the week in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 12:00:00], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        attended_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      monday_11_march_19 = DateTime.from_naive!(~N[2018-03-11 12:00:00], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_11_march_19,
        attended_at: DateTime.add(monday_11_march_19, 60, :second)
      )

      # 1 refers to the integer value of monday in the week.
      # 2 is the average count value.
      expected_results = [
        [7, 12, 3]
      ]

      assert Analytics.average_served_per_hour_per_day(waitlist.id) == expected_results
    end
  end

  describe "#average_wait_time_per_date/1" do
    test "returns the correct average wait time for customers per day in the waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)

      monday_04_march_19 = DateTime.from_naive!(~N[2018-03-04 00:00:00.000000], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        notified_at: DateTime.add(monday_04_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        notified_at: DateTime.add(monday_04_march_19, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: monday_04_march_19,
        notified_at: DateTime.add(monday_04_march_19, 180, :second)
      )

      # an_hour_ago = DateTime.utc_now
      #                 |> DateTime.add(-(3600 * 1), :second)
      tuesday_05_march_19 = DateTime.from_naive!(~N[2018-03-05 00:00:00.000000], "Etc/UTC")

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: tuesday_05_march_19,
        notified_at: DateTime.add(tuesday_05_march_19, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: tuesday_05_march_19,
        notified_at: DateTime.add(tuesday_05_march_19, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: tuesday_05_march_19,
        notified_at: DateTime.add(tuesday_05_march_19, 180, :second)
      )

      # the 2 refers to 2 minutes
      expected_results = [
        [monday_04_march_19 |> DateTime.to_naive(), 2],
        [tuesday_05_march_19 |> DateTime.to_naive(), 2]
      ]

      assert Analytics.average_wait_time_per_date(waitlist.id) == expected_results
    end
  end
end
