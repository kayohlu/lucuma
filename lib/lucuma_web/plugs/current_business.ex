defmodule LucumaWeb.Plugs.CurrentBusiness do
  import Plug.Conn
  alias Lucuma.Accounts

  def assign_current_business(conn, _params) do
    business = Accounts.get_current_business_for_user(conn.assigns.current_user)

    conn
    |> assign(:current_business, business)
  end
end
