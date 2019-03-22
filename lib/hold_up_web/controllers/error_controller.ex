defmodule HoldUpWeb.ErrorController do
  use Phoenix.Controller
  alias HoldUpWeb.ErrorView
  alias HoldUpWeb.LayoutView

  def call(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> put_layout({HoldUpWeb.LayoutView, :app})
    |> render(:"404")
  end
end
