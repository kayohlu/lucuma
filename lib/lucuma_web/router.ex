defmodule LucumaWeb.Router do
  use LucumaWeb, :router

  import LucumaWeb.Plugs.RedirectLoggedIn
  import LucumaWeb.Plugs.Authentication
  import LucumaWeb.Plugs.CurrentCompany
  import LucumaWeb.Plugs.CurrentBusiness
  import LucumaWeb.Plugs.LimitTrial
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :redirect_if_logged_in
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :authenticated?
    plug :assign_current_company
    plug :assign_current_business
    plug :limit_trial_accounts
    plug :show_trial_limit_warning

    plug :put_layout, {LucumaWeb.LayoutView, :logged_in}
  end

  scope "/", LucumaWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/registration", RegistrationController, only: [:show], singleton: true
    resources "/sessions", SessionController, only: [:new, :create]
  end

  scope "/stand_bys", LucumaWeb.StandBys, as: :stand_bys do
    pipe_through :browser

    resources "/c", CancellationController, only: [:show, :index]
  end

  scope "/callbacks", LucumaWeb do
    pipe_through :api

    resources "/sms_statuses/:sms_notification_id", SmsStatusController, only: [:create]
  end

  scope "/", LucumaWeb do
    pipe_through :protected

    delete "/signout", SessionController, :delete
    resources "/dashboard", DashboardController, only: [:show], singleton: true
    resources "/invitations", InvitationController, only: [:new, :create]
  end

  scope "/waitlists", LucumaWeb.Waitlists, as: :waitlists do
    pipe_through :protected

    resources "/", WaitlistController do
      resources "/stand_bys", StandByController, only: [:new, :create]
      resources "/settings", SettingController, only: [:index, :update]
      resources "/analytics", AnalyticsController, only: [:index]
    end
  end

  scope "/stand_bys", LucumaWeb.StandBys, as: :stand_bys do
    pipe_through :protected

    resources "/notifications", NotificationController, only: [:create]
    resources "/attendances", AttendanceController, only: [:create]
    resources "/no_shows", NoShowController, only: [:create]
    resources "/c", CancellationController, only: [:show, :index]
  end

  scope "/settings", LucumaWeb.Settings, as: :settings do
    pipe_through :protected

    resources "/profile", ProfileController, only: [:show, :update], singleton: true
    resources "/password_change", PasswordChangeController, only: [:update], singleton: true
    resources "/billing", BillingController, only: [:show], singleton: true
    resources "/staff", StaffController, only: [:show], singleton: true
    resources "/staff", StaffController, only: [:delete]
  end

  scope "/billing", LucumaWeb.Billing, as: :billing do
    pipe_through :protected

    get "/payment_plans/:id", PaymentPlanController, :edit
    resources "/payment_plans/", PaymentPlanController, only: [:update]
    resources "/subscriptions/", SubscriptionController, only: [:delete, :update]
    resources "/subscriptions_skip/", SubscriptionSkipController, only: [:create]
  end

  scope "/billing", LucumaWeb.Billing, as: :billing do
    pipe_through :api

    resources "/webhooks/", WebhookController, only: [:create]
  end

  scope "/", LucumaWeb do
    pipe_through :browser

    resources "/invitations", InvitationController, only: [:show, :update], as: :invitations do
      resources "/expiry", InvitationExpiryController, only: [:show], singleton: true
    end
  end
end
