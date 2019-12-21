defmodule LucumaWeb.PageController do
  use LucumaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
