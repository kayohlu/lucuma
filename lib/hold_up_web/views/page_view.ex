defmodule HoldUpWeb.PageView do
  use HoldUpWeb, :view

  def payment_plan_links do
    %{
      pay_as_you_go:
        Routes.registration_path(HoldUpWeb.Endpoint, :new, payment_plan_id: "plan_Eyp0J9dUxi2tWW"),
      standard:
        Routes.registration_path(HoldUpWeb.Endpoint, :new, payment_plan_id: "plan_Eyox8DhvcBMAaS"),
      unlimited:
        Routes.registration_path(HoldUpWeb.Endpoint, :new, payment_plan_id: "plan_F7YntQ0ELRD33U")
    }
  end
end
