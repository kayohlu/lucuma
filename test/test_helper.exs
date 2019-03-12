{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:wallaby)

# Provide a base URL for wallaby to use so it knows how to resolve relative paths.
Application.put_env(:wallaby, :base_url, HoldUpWeb.Endpoint.url())

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(HoldUp.Repo, :manual)
