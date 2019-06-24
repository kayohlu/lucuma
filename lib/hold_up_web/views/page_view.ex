defmodule HoldUpWeb.PageView do
  use HoldUpWeb, :view

  def payment_plan_links(conn) do
    %{
      pay_as_you_go: pay_as_you_go_link(conn),
      standard: standard_link(conn),
      unlimited: unlimited_link(conn)
    }
  end

  def pay_as_you_go_link(conn) do
    generate_new_sub_link(conn, "plan_Eyp0J9dUxi2tWW")
  end

  def standard_link(conn) do
    generate_new_sub_link(conn, "plan_Eyox8DhvcBMAaS")
  end

  def unlimited_link(conn) do
    generate_new_sub_link(conn, "plan_F7YntQ0ELRD33U")
  end

  def generate_new_sub_link(conn, plan_id) do
    link gettext("Choose plan"), to: Routes.registration_path(HoldUpWeb.Endpoint, :new, payment_plan_id: plan_id), class: "btn btn-primary pricing-action"
  end
end
