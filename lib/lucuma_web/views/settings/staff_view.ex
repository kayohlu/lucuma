defmodule LucumaWeb.Settings.StaffView do
  use LucumaWeb, :view

  def invite_status(staff_member) do
    if staff_member.invitation_token do
      if staff_member.invitation_accepted_at do
        ~E(
          <span class="lbadge lbadge-sm lbadge-success">Accepted</span>
        )
      else
        ~E(
          <span class="lbadge lbadge-sm lbadge-info">Invited</span>
        )
      end
    end
  end

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
