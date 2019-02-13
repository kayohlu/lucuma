defmodule HoldUpWeb.NavigationHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Decides whether to make the link active or not.
  """

  def activate_link(conn, link_path) do
    if conn.request_path == link_path, do: 'active', else: nil
  end
end
