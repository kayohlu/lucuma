defmodule LucumaWeb.Plugs.LimitTrial do
  import Plug.Conn

  alias Lucuma.Accounts
  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.Analytics

  def limit_trial_accounts(conn, _params) do
    waitlist = Waitlists.get_business_waitlist(conn.assigns.current_business.id)

    if Analytics.total_waitlisted(waitlist.id) >= Waitlists.trial_limit do
      conn
      |> assign(:trial_limit_reached, true)
    else
      conn
      |> assign(:trial_limit_reached, false)
    end
  end
end

