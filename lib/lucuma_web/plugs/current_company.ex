defmodule LucumaWeb.Plugs.CurrentCompany do
  import Plug.Conn
  alias Lucuma.Accounts

  def assign_current_company(conn, _params) do
    company = Accounts.get_current_company(conn.assigns.current_user)

    conn
    |> assign(:current_company, company)
  end
end
