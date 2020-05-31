defmodule LucumaWeb.Plugs.LimitTrial do
  import Plug.Conn

  alias Lucuma.Accounts
  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.Analytics
  alias Lucuma.Billing

  def limit_trial_accounts(conn, _params) do
    business = conn.assigns.current_business

    if Billing.subscription_active?(conn.assigns.current_company) do
      conn
      |> assign(:trial_limit_reached, false)
    else
      if Analytics.total_waitlisted(business) >= Waitlists.trial_limit() do
        conn
        |> assign(:trial_limit_reached, true)
      else
        conn
        |> assign(:trial_limit_reached, false)
      end
    end
  end

  def show_trial_limit_warning(conn, _params) do
    business = conn.assigns.current_business

    if Billing.subscription_active?(conn.assigns.current_company) do
      conn
      |> assign(:show_trial_limit_warning, nil)
    else
      conn
      |> assign(:show_trial_limit_warning, Waitlists.trial_remainder(business))
    end
  end
end
