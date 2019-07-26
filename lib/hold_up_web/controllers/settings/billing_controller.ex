defmodule HoldUpWeb.Settings.BillingController do
  use HoldUpWeb, :controller

  alias HoldUp.Billing

  plug :put_layout, :settings

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
