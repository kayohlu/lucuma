defmodule LucumaWeb.Waitlists.WaitlistView do
  use LucumaWeb, :view

  def time_waited(stand_by) do
    round(NaiveDateTime.diff(NaiveDateTime.utc_now(), stand_by.inserted_at) / 60)
  end

  def render("sub_navigation.html", %{waitlist: _waitlist} = assigns) do
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
end
