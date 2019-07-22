defmodule HoldUp.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias HoldUp.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import HoldUpWeb.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HoldUp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(HoldUp.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(HoldUp.Repo, self())

    {:ok, session} =
      Wallaby.start_session(metadata: metadata, window_size: [width: 1200, height: 1200])

    IO.inspect(session)

    {:ok, session: session}
  end
end
