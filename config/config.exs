# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hold_up,
  ecto_repos: [HoldUp.Repo]

# Configures the endpoint
config :hold_up, HoldUpWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lLy5QMpqK1F/HGZMKhlUuQiYjw55Mj30C3J4v2C4Celns19UMTZjKi2xUyBYLVv8",
  render_errors: [view: HoldUpWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HoldUp.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
     signing_salt: "imxM3waFXGZE2VjX6SsfoTsv/6EbYmC3"
   ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET_KEY")
config :stripity_stripe, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
