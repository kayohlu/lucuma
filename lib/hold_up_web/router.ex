defmodule HoldUpWeb.Router do
  use HoldUpWeb, :router

  import HoldUpWeb.Plugs.Authentication

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
    plug :authenticate_user

    plug :put_layout, {HoldUpWeb.LayoutView, :logged_in}
  end

  scope "/", HoldUpWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
  end

  scope "/", HoldUpWeb do
    pipe_through :protected

    delete "/signout", SessionController, :delete
    resources "/dashboard", DashboardController, only: [:index]
    resources "/stand_bys", StandByController, only: [:new, :create]
  end

  scope "/waitlist", HoldUpWeb.Waitlists, as: :waitlists do
    pipe_through :protected

    resources "/", WaitlistController, only: [:index]
    resources "/sms_settings", SmsSettingController, only: [:index, :update]
  end

  scope "/stand_bys", HoldUpWeb.StandBys, as: :stand_bys do
    pipe_through :protected

    resources "/notifications", NotificationController, only: [:create]
    resources "/attendances", AttendanceController, only: [:create]
    resources "/no_shows", NoShowController, only: [:create]
  end
end