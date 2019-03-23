defimpl Canada.Can, for: HoldUp.Accounts.Business do
  def can?(%HoldUp.Accounts.Business{id: business_id}, action, %HoldUp.Waitlists.Waitlist{business_id: business_id}) when action in [:read, :update] do
    true
  end

  def can?(_, _, _) do
    false
  end
end