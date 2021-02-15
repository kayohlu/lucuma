use Mix.Config

# config :lucuma, Lucuma.Repo,
#   ssl: true,
#   url: System.get_env("DATABASE_URL"),
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
config :lucuma, Lucuma.Repo,
  username: "postgres",
  password: "postgres",
  database: "lucuma_production",
  hostname: "localhost",
  pool_size: 10
