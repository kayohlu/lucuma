defmodule LucumaWeb.Emails.InvitationEmailTest do
  use ExUnit.Case
  use Lucuma.DataCase, async: false

  import Lucuma.Factory
  use Phoenix.HTML, only: [sigil_e: 2, content_tag: 3]

  test "invitation email" do
    company = insert(:company)
    business = insert(:business, company: company)
    user = insert(:user, company: company, roles: ["company_admin"])
    user_business = insert(:user_business, user_id: user.id, business_id: business.id)

    invited_user =
      insert(:user, invited_by_id: user.id, inviter: user, company: company, roles: ["staff"])

    insert(:user_business, user_id: invited_user.id, business_id: business.id)

    email = LucumaWeb.Emails.Email.invitation_email(invited_user)

    assert email.to == invited_user.email
    assert email.from == "noreply@holdup.com"
    assert email.html_body == invitation_email_content(invited_user)
  end

  def invitation_email_content(invited_user) do
    accept_link =
      LucumaWeb.Router.Helpers.invitations_url(
        LucumaWeb.Endpoint,
        :show,
        invited_user.invitation_token
      )

    ~e"""
    Hi <%= invited_user.full_name %>,

    You've been invited by <%= invited_user.inviter.full_name %>. Please use the following link to accept your invitation:

    <%= content_tag(
      :p,
      link("Accept Invite", to: accept_link)
    )
    %>

    """
  end
end
