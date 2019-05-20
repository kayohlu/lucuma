defmodule HoldUpWeb.Billing.PaymentPlanController do
  use HoldUpWeb, :controller

  alias HoldUp.Billing
  alias HoldUp.Billing.PaymentPlan

  plug :put_layout, {HoldUpWeb.LayoutView, :only_form} when action in [:edit, :update]

  def edit(conn, %{"id" => id}) do
    render(conn, "edit.html", id: id)
  end

  def update(conn, params) do
    %{"id" => stripe_payment_plan_id, "stripeToken" => stripe_credit_card_token} = params

    case Billing.create_subscription(conn.assigns.current_user, conn.assigns.current_company, params) do
      :ok ->
        conn
        |> put_flash(:info, "You're subscription has now been activated. To cancel or change your plan, visit your profile.")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, message} ->
        conn
        |> render("edit.html", id: stripe_payment_plan_id, error_message: "Subscription failed. #{message}")
    end
  end
end