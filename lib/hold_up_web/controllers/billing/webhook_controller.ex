defmodule HoldUpWeb.Billing.WebhookController do
  use HoldUpWeb, :controller

  require Logger

  alias HoldUp.Billing

  def create(conn, params) do
    IO.inspect(conn)

    signature = Plug.Conn.get_req_header(conn, "stripe-signature") |> List.first()

    case Stripe.Webhook.construct_event(
           conn.assigns.raw_body,
           signature,
           System.get_env("STRIPE_WEB_HOOK_SECRET")
         ) do
      {:ok, stripe_event} ->
        handle_event(stripe_event.type, stripe_event)

        conn
        |> send_resp(200, "")

      {:error, reason} ->
        send_resp(conn, 400, "")
    end
  end

  def handle_event("invoice.payment_failed", stripe_event) do
    Logger.info("handling invoice.payment_failed")
    Billing.handle_invoice_payment_fail(stripe_event)
  end
end
