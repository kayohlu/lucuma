defmodule LucumaWeb.Permissions do
  require Logger
  import Phoenix.Controller
  import Plug.Conn

  defmacro __using__(opts) do
    quote do
      require Logger
      import LucumaWeb.Permissions

      def action(conn, _) do
        controller = Phoenix.Controller.controller_module(conn)
        action = Phoenix.Controller.action_name(conn)
        args = [conn, conn.params]

        if Map.has_key?(conn.assigns, :current_user) do
          [role | _] = conn.assigns.current_user.roles
          Logger.info("Checking permissions for user_id: #{conn.assigns.current_user.id}")
          Logger.info("Role for user_id #{conn.assigns.current_user.id} is #{role}.")

          if has_permission?(conn, role, controller, action) do
            Logger.info(
              "user_id #{conn.assigns.current_user.id} has permission on #{controller}##{action}"
            )

            apply(__MODULE__, action, args)
          else
            Logger.info(
              "user_id #{conn.assigns.current_user.id} has NO permission on #{controller}##{
                action
              }, handling un authorisation.."
            )

            handle_un_authorisation(conn)
          end
        else
          Logger.info(":currenet_user key not existing in the structure.")
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
        actions =
          get_in(permission_rules, [role, controller])
          |> Map.keys()

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
        LucumaWeb.SessionController => [:delete],
        LucumaWeb.DashboardController => [:show],
        LucumaWeb.InvitationController => [:new, :create],

        # waitlists
        LucumaWeb.Waitlists.WaitlistController => %{
          index: true,
          show: fn conn ->
            waitlist_id = conn.params["id"]
            waitlist = Lucuma.Waitlists.get_waitlist!(waitlist_id)
            conn.assigns.current_business.id == waitlist.business_id
          end
        },
        LucumaWeb.Waitlists.StandByController => [:new, :create],
        LucumaWeb.Waitlists.SettingController => %{
          index: fn conn ->
            waitlist_id = conn.params["waitlist_id"]
            waitlist = Lucuma.Waitlists.get_waitlist!(waitlist_id)
            conn.assigns.current_business.id == waitlist.business_id
          end,
          update: fn conn ->
            waitlist_id = conn.params["waitlist_id"]
            waitlist = Lucuma.Waitlists.get_waitlist!(waitlist_id)
            conn.assigns.current_business.id == waitlist.business_id
          end
        },
        LucumaWeb.Waitlists.AnalyticsController => [:index],

        # stand bys
        LucumaWeb.StandBys.NotificationController => [:create],
        LucumaWeb.StandBys.AttendanceController => [:create],
        LucumaWeb.StandBys.NoShowController => [:create],
        LucumaWeb.StandBys.CancellationController => [:show, :index],

        # settings
        LucumaWeb.Settings.ProfileController => [:show, :update],
        LucumaWeb.Settings.BillingController => [:show],
        LucumaWeb.Settings.StaffController => [:show, :delete],
        LucumaWeb.Settings.PasswordChangeController => [:update],

        # billing
        LucumaWeb.Billing.PaymentPlanController => [:edit, :update],
        LucumaWeb.Billing.SubscriptionController => [:delete, :update],
        LucumaWeb.Billing.SubscriptionSkipController => [:create]
      },
      "staff" => %{
        LucumaWeb.SessionController => [:delete],
        LucumaWeb.DashboardController => [:show],

        # waitlists
        LucumaWeb.Waitlists.WaitlistController => [:index, :show],
        LucumaWeb.Waitlists.StandByController => [:new, :create],
        LucumaWeb.Waitlists.AnalyticsController => [:index],

        # stand bys
        LucumaWeb.StandBys.NotificationController => [:create],
        LucumaWeb.StandBys.AttendanceController => [:create],
        LucumaWeb.StandBys.NoShowController => [:create],

        # settings
        LucumaWeb.Settings.ProfileController => [:show, :update],
        LucumaWeb.Settings.PasswordChangeController => [:update]
      }
    }
  end

  def handle_un_authorisation(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(LucumaWeb.ErrorView)
    |> put_layout({LucumaWeb.LayoutView, :app})
    |> render(:"404")
    |> halt()
  end
end
