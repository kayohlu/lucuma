defmodule LucumaWeb.Settings.ProfileView do
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
        path: Routes.settings_profile_path(assigns.conn, :show),
        text: gettext("Profile")
      }
    ]

    links =
      if LucumaWeb.Permissions.permitted_to?(
           assigns.conn,
           LucumaWeb.Settings.BillingController,
           :show
         ) do
        links ++
          [
            %{
              path: Routes.settings_billing_path(assigns.conn, :show),
              text: gettext("Billing")
            }
          ]
      else
        links
      end

    if LucumaWeb.Permissions.permitted_to?(
         assigns.conn,
         LucumaWeb.Settings.StaffController,
         :show
       ) do
      links ++
        [
          %{
            path: Routes.settings_staff_path(assigns.conn, :show),
            text: gettext("Staff")
          }
        ]
    else
      links
    end
  end
end
