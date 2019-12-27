defmodule LucumaWeb.Plugs.LimitTrial do
  import Plug.Conn

  alias Lucuma.Accounts
  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.Analytics
  alias Lucuma.Billing

  def limit_trial_accounts(conn, _params) do
    waitlist = Waitlists.get_business_waitlist(conn.assigns.current_business.id)
    business = conn.assigns.current_business

    if Billing.subscription_active?(conn.assigns.current_company) do
      conn
      |> assign(:trial_limit_reached, false)
    else
      if Analytics.total_waitlisted(waitlist.id, business) >= Waitlists.trial_limit() do
        conn
        |> assign(:trial_limit_reached, true)
      else
        conn
        |> assign(:trial_limit_reached, false)
      end
    end
  end
end
