defmodule HoldUpWeb.Billing.PaymentPlanController do
  @moduledoc """
  This controller is used to handle subscriptions when they are registering..
  """
  use HoldUpWeb, :controller

  alias HoldUp.Billing
  alias HoldUp.Billing.PaymentPlan
  alias HoldUp.Billing.SubscriptionForm

  plug :put_layout, {HoldUpWeb.LayoutView, :only_form} when action in [:edit, :update]

  def edit(conn, %{"id" => id}) do
    if conn.assigns.current_company.stripe_subscription_id &&
         conn.assigns.current_company.stripe_payment_plan_id do
      conn
      |> put_flash(
        :info,
        "You have already subscribed."
      )
      |> redirect(to: Routes.dashboard_path(conn, :index))
    else
      changeset = Billing.change_subscription_form(%SubscriptionForm{})
      payment_plan = Billing.get_payment_plan(id)

      render(conn, "edit.html",
        id: id,
        changeset: changeset,
        payment_plan: payment_plan,
        payment_form_referer: payment_form_referer(conn)
      )
    end
  end

  def update(conn, params) do
    if conn.assigns.current_company.stripe_subscription_id &&
         conn.assigns.current_company.stripe_payment_plan_id do
      conn
      |> put_flash(
        :info,
        "You have already subscribed."
      )
      |> redirect(to: Routes.dashboard_path(conn, :index))
    else
      %{"id" => stripe_payment_plan_id, "stripeToken" => stripe_credit_card_token} = params

      res =
        Billing.create_subscription(
          conn.assigns.current_user,
          conn.assigns.current_company,
          params
        )

      case res do
        :ok ->
          conn
          |> put_flash(
            :info,
            "You're subscription has now been activated. To cancel or change your plan, visit your profile."
          )
          |> redirect(to: Routes.dashboard_path(conn, :index))

        {:error, changeset} ->
          [credit_or_debit_card: {message, []}] = changeset.errors

          conn
          |> render("edit.html",
            id: stripe_payment_plan_id,
            changeset: changeset,
            error_message: "Subscription failed. #{message}",
            payment_form_referer: payment_form_referer(conn)
          )
      end
    end
  end

  def payment_form_referer(%Plug.Conn{} = conn) do
    conn
    |> Plug.Conn.get_req_header("referer")
  end
end
