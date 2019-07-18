defmodule HoldUpWeb.ProfileController do
  use HoldUpWeb, :controller

  alias HoldUp.Accounts
  alias HoldUp.Billing

  def show(conn, params) do
    assigns =
      if conn.assigns.current_company.stripe_subscription_id == nil do
        [subscription: nil, upcoming_invoice: nil]
      else
        [
          subscription:
            Billing.get_current_subscription(conn.assigns.current_company.stripe_subscription_id),
          upcoming_invoice: Billing.upcoming_invoice(conn.assigns.current_company)
        ]
      end

    render(conn, "show.html", assigns)
  end
end
