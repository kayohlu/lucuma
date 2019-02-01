defmodule RestaurantWeb.Router do
  use RestaurantWeb, :router

  import RestaurantWeb.Plugs.Authentication

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

    plug :put_layout, {RestaurantWeb.LayoutView, :logged_in}
  end

  scope "/", RestaurantWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
  end

  scope "/", RestaurantWeb do
    pipe_through :protected

    delete "/signout", SessionController, :delete
    resources "/dashboard", DashboardController, only: [:index]
    resources "/waitlist", WaitListController, only: [:index]
    resources "/stand_bys", StandByController, only: [:new, :create]
  end

  scope "/stand_bys", RestaurantWeb.StandBys, as: :stand_bys do
    pipe_through :protected

    resources "/notifications", NotificationController, only: [:create]
    resources "/attendances", AttendanceController, only: [:create]
    resources "/no_shows", NoShowController, only: [:create]
  end
end