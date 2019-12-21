defmodule Lucuma.Repo do
  use Ecto.Repo,
    otp_app: :lucuma,
    adapter: Ecto.Adapters.Postgres
end
