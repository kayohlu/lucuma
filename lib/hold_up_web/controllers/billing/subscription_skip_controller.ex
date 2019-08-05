defmodule HoldUpWeb.Billing.SubscriptionSkipController do
  use HoldUpWeb, :controller

  def create(conn, params) do
    %{"payment_form_referer" => payment_form_referer} = params

    IO.puts(payment_form_referer)

    cond do
      [Routes.settings_billing_url(conn, :show)] == payment_form_referer ->
        redirect(conn, to: Routes.settings_billing_path(conn, :show))

      Regex.match?(~r/#{Routes.registration_url(conn, :new)}/, hd(payment_form_referer)) ->
        conn
        |> put_flash(
          :info,
          "That's it. Your registration is complete. We've created an initial default waitlist for you. You can add up to 100 people to your waitlist."
        )
        |> redirect(to: Routes.dashboard_path(conn, :show))

      true ->
        conn
        |> redirect(to: Routes.dashboard_path(conn, :show))
    end
  end
end
