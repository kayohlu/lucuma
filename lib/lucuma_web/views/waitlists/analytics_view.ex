defmodule LucumaWeb.Waitlists.AnalyticsView do
  use LucumaWeb, :view

  def render("sub_navigation.html", assigns) do
    render(
      LucumaWeb.LayoutView,
      "sub_navigation.html",
      Map.put(assigns, :sub_nav_links, sub_nav_links(assigns))
    )
  end

  def sub_nav_links(assigns) do
    links = [
      %{
        path: Routes.waitlists_waitlist_path(assigns.conn, :show, assigns.waitlist.id),
        text: gettext("Waitlist")
      },
      %{
        path: Routes.waitlists_waitlist_analytics_path(assigns.conn, :index, assigns.waitlist.id),
        text: gettext("Analytics")
      }
    ]

    if LucumaWeb.Permissions.permitted_to?(
         assigns.conn,
         LucumaWeb.Waitlists.SettingController,
         :index
       ) do
      links ++
        [
          %{
            path:
              Routes.waitlists_waitlist_setting_path(assigns.conn, :index, assigns.waitlist.id),
            text: gettext("Settings")
          }
        ]
    else
      links
    end
  end
  def inject_unix_timestamp(data) do
    data
    |> Enum.map(fn [date_str, value] ->
      {:ok, datetime_utc} = DateTime.from_naive(date_str, "Etc/UTC")
      [datetime_utc |> DateTime.to_unix(), value]
    end)
  end

  def convert_isodow_to_day_str(data) do
    day_map = %{
      1.0 => "Monday",
      2.0 => "Tuesday",
      3.0 => "Wednesday",
      4.0 => "Thursday",
      5.0 => "Friday",
      6.0 => "Saturday",
      7.0 => "Sunday"
    }

    data
    |> Enum.map(fn [day | tail] -> [day_map[day] | tail] end)
  end

  def convert_hour_int_to_hour_str(data) do
    data
    |> Enum.map(fn [hour | tail] -> ["#{trunc(hour)}:00 - #{trunc(hour + 1)}:00" | tail] end)
  end

  def convert_to_highcharts_named_series(data) do
    hours =
      convert_isodow_to_day_str(data)
      |> Enum.map(fn [day | [hour | tail]] -> hour end)
      |> Enum.uniq()

    empty_series = Enum.map(hours, fn hour -> %{name: hour, data: []} end)

    day_map = %{
      1.0 => "Monday",
      2.0 => "Tuesday",
      3.0 => "Wednesday",
      4.0 => "Thursday",
      5.0 => "Friday",
      6.0 => "Saturday",
      7.0 => "Sunday"
    }

    Enum.map(empty_series, fn %{name: set_hour, data: _empty_list} ->
      new_data =
        data
        |> Enum.filter(fn [day, hour_float, value] -> hour_float == set_hour end)
        |> Enum.map(fn [day, hour_float, value] -> [day_map[day], value] end)

      %{name: "#{set_hour}:00 - #{set_hour + 1}:00", data: new_data}
    end)
  end
end
