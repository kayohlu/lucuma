defmodule HoldUpWeb.ProfileView do
  use HoldUpWeb, :view

  def payment_plan_links do
    %{
      pay_as_you_go:
        Routes.billing_payment_plan_path(HoldUpWeb.Endpoint, :edit, "plan_Eyp0J9dUxi2tWW"),
      standard:
        Routes.billing_payment_plan_path(HoldUpWeb.Endpoint, :edit, "plan_Eyox8DhvcBMAaS"),
      unlimited: Routes.billing_payment_plan_path(HoldUpWeb.Endpoint, :edit, "plan_F7YntQ0ELRD33U")
    }
  end
end
