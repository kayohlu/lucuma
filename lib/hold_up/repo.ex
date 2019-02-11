defmodule HoldUp.Repo do
  use Ecto.Repo,
    otp_app: :hold_up,
    adapter: Ecto.Adapters.Postgres
end
