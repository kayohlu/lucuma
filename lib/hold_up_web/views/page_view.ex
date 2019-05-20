defmodule HoldUpWeb.PageView do
  use HoldUpWeb, :view


  def payment_plan_links do
    %{
      pay_as_you_go: nil,
      standard: nil,
      unlimited: nil
    }
  end
end
