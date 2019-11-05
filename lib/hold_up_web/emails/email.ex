defmodule HoldUpWeb.Emails.Email do
  import Bamboo.Email
  use Phoenix.HTML

  alias HoldUpWeb.Router.Helpers, as: Routes

  def invitation_email(invited_user) do
    new_email(
      to: invited_user.email,
      from: "noreply@holdup.com",
      subject: "HoldUp Invitation",
      html_body: invitation_email_content(invited_user)
    )
  end

  def invitation_email_content(invited_user) do
    accept_link = Routes.invitations_url(HoldUpWeb.Endpoint, :show, invited_user.invitation_token)

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
