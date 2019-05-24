defmodule HoldUpWeb.Billing.SubscriptionController do
  use HoldUpWeb, :controller

  alias HoldUp.Billing
  alias HoldUp.Billing.PaymentPlan
  alias HoldUp.Billing.SubscriptionForm

  # plug :put_layout, {HoldUpWeb.LayoutView, :only_form} when action in [:edit, :update]

  def delete(conn, params) do
    %{"id" => stripe_payment_plan_id} = params

    flash_opts = case Billing.cancel_subscription(conn.assigns.current_user, conn.assigns.current_company, params) do
      :ok -> [conn, :info, "You're subscription has now been canceled."]
      {:error, _} ->  [conn, :error, "You're subscription could not be canceled."]
    end

    apply(Phoenix.Controller, :put_flash, flash_opts)
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end
end