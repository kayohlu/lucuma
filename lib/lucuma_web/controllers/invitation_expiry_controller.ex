defmodule LucumaWeb.InvitationExpiryController do
  use LucumaWeb, :controller

  plug :put_layout, {LucumaWeb.LayoutView, :only_form}

  def show(conn, _params) do
    IO.inspect("show invitation expiry")
    render(conn, "show.html")
  end
end
