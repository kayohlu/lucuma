defmodule HoldUpWeb.Permissions do
  def permission_rules do
    # List of roles ["master_admin", "company_admin", "business_admin", "staff"]
    %{
      "company_admin" => %{
        HoldUpWeb.SessionController => [:delete],
        HoldUpWeb.DashboardController =>  [:show],
        HoldUpWeb.InvitationController => [:new, :create],

        # waitlists
        HoldUpWeb.Waitlists.WaitlistController => [:index, :show],
        HoldUpWeb.Waitlists.StandByController => [:new, :create],
        HoldUpWeb.Waitlists.SettingController => [:index, :update],
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
        HoldUpWeb.DashboardController =>  [:show],

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
end