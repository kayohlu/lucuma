defmodule HoldUpWeb.Features.DashboardTest do
  use HoldUp.FeatureCase, async: false

  import HoldUp.Factory
  import Wallaby.Query

  describe "dashboard" do
    test "shows today's stats and busiest hours for this day", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      {:ok, today_mid_day} =
        Date.utc_today()
        |> NaiveDateTime.new(~T[12:00:00])

      today_mid_day = DateTime.from_naive!(today_mid_day, "Etc/UTC")

      {:ok, yesterday_mid_day} =
        Date.utc_today()
        |> Timex.shift(days: -1)
        |> NaiveDateTime.new(~T[12:00:00])

      yesterday_mid_day = DateTime.from_naive!(yesterday_mid_day, "Etc/UTC")

      {:ok, this_day_last_week} =
        Date.utc_today()
        |> Timex.shift(days: -7)
        |> NaiveDateTime.new(~T[12:00:00])

      this_day_last_week_mid_day = DateTime.from_naive!(this_day_last_week, "Etc/UTC")

      # Today
      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        notified_at: DateTime.add(today_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        attended_at: DateTime.add(today_mid_day, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day,
        attended_at: DateTime.add(today_mid_day, 180, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: today_mid_day
      )

      # This day last week
      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: this_day_last_week_mid_day,
        attended_at: DateTime.add(this_day_last_week_mid_day, 60, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: this_day_last_week_mid_day,
        attended_at: DateTime.add(this_day_last_week_mid_day, 120, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: this_day_last_week_mid_day,
        attended_at: DateTime.add(this_day_last_week_mid_day, 180, :second)
      )

      insert(:stand_by,
        waitlist_id: waitlist.id,
        inserted_at: this_day_last_week_mid_day,
        attended_at: DateTime.add(this_day_last_week_mid_day, 60, :second)
      )

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))

      # waitlisted
      page
      |> find(css(".col.text-center.align-self-center", count: 3, at: 0))
      |> assert_text("4")

      # waiting
      page
      |> find(css(".col.text-center.align-self-center", count: 3, at: 1))
      |> assert_text("1")

      # average wait time
      page
      |> find(css(".col.text-center.align-self-center", count: 3, at: 2))
      |> assert_text("1")
    end
  end
end
