# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lucuma,
  ecto_repos: [Lucuma.Repo]

# Configures the endpoint
config :lucuma, LucumaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lLy5QMpqK1F/HGZMKhlUuQiYjw55Mj30C3J4v2C4Celns19UMTZjKi2xUyBYLVv8",
  render_errors: [view: LucumaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lucuma.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "imxM3waFXGZE2VjX6SsfoTsv/6EbYmC3"
  ]

config :lucuma, LucumaWeb.Endpoint,
  pubsub: [adapter: Phoenix.PubSub.PG2,
    pool_size: 1,
    name: LucumaWeb.PubSub]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET_KEY")
config :stripity_stripe, json_library: Jason

config :lucuma, LucumaWeb.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: {:system, "MAILGUN_PRIVATE_API_KEY"},
  domain: {:system, "MAILGUN_DOMAIN"}

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
