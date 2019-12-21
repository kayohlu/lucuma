defmodule LucumaWeb.ErrorController do
  use Phoenix.Controller
  alias LucumaWeb.ErrorView
  alias LucumaWeb.LayoutView

  def call(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> put_layout({LucumaWeb.LayoutView, :app})
    |> render(:"404")
  end
end
