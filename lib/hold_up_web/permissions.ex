defmodule HoldUpWeb.Permissions do
  require Logger
  import Phoenix.Controller
  import Plug.Conn

  defmacro __using__(opts) do
    quote do
      import HoldUpWeb.Permissions

      def action(conn, _) do
        controller = Phoenix.Controller.controller_module(conn)
        action = Phoenix.Controller.action_name(conn)
        args = [conn, conn.params]

        if Map.has_key?(conn.assigns, :current_user) do
          [role | _] = conn.assigns.current_user.roles

          if has_permission?(conn, role, controller, action) do
            apply(__MODULE__, action, args)
          else
            handle_un_authorisation(conn)
          end
        else
          apply(__MODULE__, action, args)
        end
      end
    end
  end

  @doc """
  This function should only be used to check permissions in views.
  It does not run the callbacks to check the rule since it we are only really
  concerned with the actions under the controller that are allowed for a role.
  """
  def permitted_to?(conn, controller, action) do
    [role | _] = conn.assigns.current_user.roles

    if get_in(permission_rules, [role, controller]) == nil do
      Logger.info(
        "No entry in permissions map for #{role}, #{controller}. The action was #{action}"
      )

      false
    else
      if is_list(get_in(permission_rules, [role, controller])) do
        action in get_in(permission_rules, [role, controller])
      else
        # get the keys in the hash
        actions = get_in(permission_rules, [role, controller])
        |> Map.keys

        action in actions
      end
    end
  end

  @doc """
  This function should only be used to check permissions on requests.
  """
  def has_permission?(conn, role, controller, action) do
    if get_in(permission_rules, [role, controller]) == nil do
      Logger.info(
        "No entry in permissions map for #{role}, #{controller}. The action was #{action}"
      )

      false
    else
      if is_list(get_in(permission_rules, [role, controller])) do
        action in get_in(permission_rules, [role, controller])
      else
        if is_function(get_in(permission_rules, [role, controller, action])) do
          permission_fn = get_in(permission_rules, [role, controller, action])
          permission_fn.(conn)
        else
          get_in(permission_rules, [role, controller, action])
        end
      end
    end
  end

  def permission_rules do
    # List of roles ["master_admin", "company_admin", "business_admin", "staff"]
    %{
      "company_admin" => %{
        HoldUpWeb.SessionController => [:delete],
        HoldUpWeb.DashboardController => [:show],
        HoldUpWeb.InvitationController => [:new, :create],

        # waitlists
        HoldUpWeb.Waitlists.WaitlistController => %{
          index: true,
          show: fn conn ->
            waitlist_id = conn.params["id"]
            waitlist = HoldUp.Waitlists.get_waitlist!(waitlist_id)
            conn.assigns.current_business.id == waitlist.business_id
          end
        },
        HoldUpWeb.Waitlists.StandByController => [:new, :create],
        HoldUpWeb.Waitlists.SettingController => %{
          index: fn conn ->
            waitlist_id = conn.params["waitlist_id"]
            waitlist = HoldUp.Waitlists.get_waitlist!(waitlist_id)
            conn.assigns.current_business.id == waitlist.business_id
          end,
          update: fn conn ->
            waitlist_id = conn.params["waitlist_id"]
            waitlist = HoldUp.Waitlists.get_waitlist!(waitlist_id)
            conn.assigns.current_business.id == waitlist.business_id
          end
        },
        HoldUpWeb.Waitlists.AnalyticsController => [:index],

        # stand bys
        HoldUpWeb.StandBys.NotificationController => [:create],
        HoldUpWeb.StandBys.AttendanceController => [:create],
        HoldUpWeb.StandBys.NoShowController => [:create],
        HoldUpWeb.StandBys.CancellationController => [:show, :index],

        # settings
        HoldUpWeb.Settings.ProfileController => [:show],
        HoldUpWeb.Settings.BillingController => [:show],
        HoldUpWeb.Settings.StaffController => [:show, :delete],

        # billing
        HoldUpWeb.Billing.PaymentPlanController => [:edit],
        HoldUpWeb.Billing.PaymentPlanController => [:update],
        HoldUpWeb.Billing.SubscriptionController => [:delete, :update],
        HoldUpWeb.Billing.SubscriptionSkipController => [:create]
      },
      "staff" => %{
        HoldUpWeb.SessionController => [:delete],
        HoldUpWeb.DashboardController => [:show],

        # waitlists
        HoldUpWeb.Waitlists.WaitlistController => [:index, :show],
        HoldUpWeb.Waitlists.StandByController => [:new, :create],
        HoldUpWeb.Waitlists.AnalyticsController => [:index],

        # stand bys
        HoldUpWeb.StandBys.NotificationController => [:create],
        HoldUpWeb.StandBys.AttendanceController => [:create],
        HoldUpWeb.StandBys.NoShowController => [:create],

        # settings
        HoldUpWeb.Settings.ProfileController => [:show]
      }
    }
  end

  def handle_un_authorisation(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(HoldUpWeb.ErrorView)
    |> put_layout({HoldUpWeb.LayoutView, :app})
    |> render(:"404")
    |> halt()
  end
end
