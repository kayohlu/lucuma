defmodule HoldUpWeb.ProfileController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts
  alias HoldUp.Billing

  def show(conn, params) do
    subscription =
      Billing.get_current_subscription(conn.assigns.current_company.stripe_subscription_id)

    upcoming_invoice = Billing.upcoming_invoice(conn.assigns.current_company)

    render(conn, "show.html", subscription: subscription, upcoming_invoice: upcoming_invoice)
  end
end
