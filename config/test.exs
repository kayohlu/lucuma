use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hold_up, HoldUpWeb.Endpoint,
  http: [port: 4002],
  server: true

config :hold_up, sql_sandbox: true

# Print only warnings and errors during test
config :logger, level: :debug

# Configure your database
config :hold_up, HoldUp.Repo,
  username: "postgres",
  password: "postgres",
  database: "hold_up_test",
  hostname: if(System.get_env("CI"), do: "postgres", else: "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

# Don't slow down test suite because of bcrypt.
config :bcrypt_elixir, :log_rounds, 4

config :wallaby,
  driver: Wallaby.Experimental.Chrome