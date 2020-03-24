defmodule Lucuma.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    if Mix.env() == :prod do
      Lucuma.Release.migrate()
    end

    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Lucuma.Repo,
      # Start the endpoint when the application starts
      LucumaWeb.Endpoint,
      # Starts a worker by calling: Lucuma.Worker.start_link(arg)
      # {Lucuma.Worker, arg},
      {Lucuma.Notifications.NotificationProducer, [0]},
      {Lucuma.Notifications.NotificationConsumer, []},
      {
        DynamicSupervisor,
        strategy: :one_for_one, name: Lucuma.NotifierDynamicSupervisor
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lucuma.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LucumaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
