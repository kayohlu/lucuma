defmodule LucumaWeb.Waitlists.WaitlistView do
  use LucumaWeb, :view

  def time_waited(stand_by) do
    round(NaiveDateTime.diff(NaiveDateTime.utc_now(), stand_by.inserted_at) / 60)
  end
end
