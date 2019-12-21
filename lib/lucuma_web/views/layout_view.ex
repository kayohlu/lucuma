defmodule LucumaWeb.LayoutView do
  use LucumaWeb, :view

  def render_layout(layout, assigns, do: content) do
    render(layout, Map.put(assigns, :inner_layout, content))
  end
end
