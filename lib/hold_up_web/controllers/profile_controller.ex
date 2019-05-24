defmodule HoldUpWeb.ProfileController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts

  def show(conn, params) do
    render(conn, "show.html")
  end
end
