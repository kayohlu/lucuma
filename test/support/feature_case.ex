defmodule Lucuma.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Lucuma.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import LucumaWeb.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Lucuma.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Lucuma.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Lucuma.Repo, self())

    {:ok, session} =
      Wallaby.start_session(metadata: metadata, window_size: [width: 1200, height: 1400])

    {:ok, session: session}
  end
end
