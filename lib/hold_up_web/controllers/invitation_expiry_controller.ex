defmodule HoldUpWeb.InvitationExpiryController do
  use HoldUpWeb, :controller

  plug :put_layout, {HoldUpWeb.LayoutView, :only_form}

  def show(conn, _params) do
    IO.inspect("show invitation expiry")
    render(conn, "show.html")
  end
end
