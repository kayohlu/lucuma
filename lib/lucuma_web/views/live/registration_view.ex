defmodule LucumaWeb.Live.RegistrationView do
  use Phoenix.LiveView
  import LucumaWeb.Gettext

  alias Lucuma.Registrations
  alias Registrations.RegistrationForm
  alias Lucuma.Billing
  alias Lucuma.Billing.SubscriptionForm
  alias LucumaWeb.Router.Helpers, as: Routes

  def render(assigns) do
    LucumaWeb.RegistrationView.render("show.html", assigns)
  end

  def mount(params, session, socket) do
    %{"payment_plan_id" => payment_plan_id} = session

    assigns = [
      account_details_changeset: Registrations.change_registration_form(%RegistrationForm{}),
      action: "#",
      current_step: "account_details",
      payment_plan_id: payment_plan_id
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("save_account_details", %{"registration" => attrs} = params, socket) do
    assigns =
      case Registrations.create_registration_form(attrs) do
        {:ok, results} ->
          account_details_by_id = Enum.into(results, %{}, fn {k,v} -> {k,v.id} end)
          [
            account_details: results,
            subscription_changeset: Billing.change_subscription_form(%SubscriptionForm{}),
            current_step: "subscription",
          ]

        {:error, account_details_changeset} ->
          [
            account_details_changeset: account_details_changeset
          ]
      end

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("create_subscription", params, socket) do
    %{account_details: %{user: user, company: company}} = socket.assigns

    %{
      "stripeToken" => stripe_credit_card_token,
      "subscription_form" => %{"id" => stripe_payment_plan_id}
    } = params

    attrs = %{"id" => stripe_payment_plan_id, "stripeToken" => stripe_credit_card_token}

    assigns =
      case Billing.create_subscription(user, company, attrs) do
        :ok ->
          [
            current_step: "complete"
          ]

        {:error, subscription_changeset} ->
          # remove
          [
            subscription_changeset: subscription_changeset
          ]
      end

    {:noreply, assign(socket, assigns)}
  end
end
