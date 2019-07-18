defmodule HoldUpWeb.Billing.SubscriptionController do
  @moduledoc """
  This controller is used to handle subscriptions when they have registered..
  """

  use HoldUpWeb, :controller

  alias HoldUp.Billing
  alias HoldUp.Billing.PaymentPlan
  alias HoldUp.Billing.SubscriptionForm

  def delete(conn, %{"id" => stripe_payment_plan_id} = params) do
    flash_opts =
      case Billing.cancel_subscription(conn.assigns.current_company, stripe_payment_plan_id) do
        :ok -> [conn, :info, "You're subscription has now been canceled."]
        {:error, _} -> [conn, :error, "You're subscription could not be canceled."]
      end

    apply(Phoenix.Controller, :put_flash, flash_opts)
    |> redirect(to: Routes.profile_path(conn, :show))
  end

  def update(conn, %{"id" => stripe_payment_plan_id} = params) do
    flash_opts =
      case Billing.update_subscription(conn.assigns.current_company, stripe_payment_plan_id) do
        {:ok, company} -> [conn, :info, "You're subscription has now been updated."]
        {:error, _} -> [conn, :error, "You're subscription could not be updated."]
      end

    apply(Phoenix.Controller, :put_flash, flash_opts)
    |> redirect(to: Routes.profile_path(conn, :show))
  end
end
