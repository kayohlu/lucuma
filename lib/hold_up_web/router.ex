defmodule HoldUpWeb.Router do
  use HoldUpWeb, :router

  import HoldUpWeb.Plugs.RedirectLoggedIn
  import HoldUpWeb.Plugs.Authentication
  import HoldUpWeb.Plugs.CurrentCompany
  import HoldUpWeb.Plugs.CurrentBusiness
  import HoldUpWeb.Plugs.Authorisation

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
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :authenticated?
    plug :assign_current_company
    plug :assign_current_business
    plug :authorise

    plug :put_layout, {HoldUpWeb.LayoutView, :logged_in}
  end

  scope "/", HoldUpWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
  end

  scope "/stand_bys", HoldUpWeb.StandBys, as: :stand_bys do
    pipe_through :browser

    resources "/c", CancellationController, only: [:show, :index]
  end

  scope "/callbacks", HoldUpWeb do
    pipe_through :api

    resources "/sms_statuses/:sms_notification_id", SmsStatusController, only: [:create]
  end

  scope "/", HoldUpWeb do
    pipe_through :protected

    delete "/signout", SessionController, :delete
    resources "/dashboard", DashboardController, only: [:index]
    resources "/profile", ProfileController, only: [:show], singleton: true
  end

  scope "/waitlists", HoldUpWeb.Waitlists, as: :waitlists do
    pipe_through :protected

    resources "/", WaitlistController, only: [:index, :show] do
      resources "/stand_bys", StandByController, only: [:new, :create]
      resources "/settings", SettingController, only: [:index, :update]
      resources "/analytics", AnalyticsController, only: [:index]
    end
  end

  scope "/stand_bys", HoldUpWeb.StandBys, as: :stand_bys do
    pipe_through :protected

    resources "/notifications", NotificationController, only: [:create]
    resources "/attendances", AttendanceController, only: [:create]
    resources "/no_shows", NoShowController, only: [:create]
    resources "/c", CancellationController, only: [:show, :index]
  end

  scope "/billing", HoldUpWeb.Billing, as: :billing do
    pipe_through :protected

    get "/payment_plans/:id", PaymentPlanController, :edit
    resources "/payment_plans/", PaymentPlanController, only: [:update]
  end
end
