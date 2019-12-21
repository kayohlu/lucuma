use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lucuma, LucumaWeb.Endpoint,
  http: [port: 4002],
  server: true

config :lucuma, sql_sandbox: true

# Print only warnings and errors during test
config :logger, level: :debug

# Configure your database
config :lucuma, Lucuma.Repo,
  username: "postgres",
  password: "postgres",
  database: "lucuma_test",
  hostname: if(System.get_env("CI"), do: "postgres", else: "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

# Don't slow down test suite because of bcrypt.
config :bcrypt_elixir, :log_rounds, 4

config :wallaby,
  driver: Wallaby.Experimental.Chrome,
  chrome: [
    headless: true
  ]

config :lucuma, LucumaWeb.Mailer, adapter: Bamboo.TestAdapter
