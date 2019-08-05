defmodule HoldUpWeb.Emails.Email do
  use Bamboo.Phoenix, view: HoldUpWeb.EmailView

  def invitation_email(invited_user) do
    new_email(
      to: "john@example.com",
      from: "support@myapp.com",
      subject: "Invitation",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
  end

  def invitation_email_content(invited_user) do
    ~e"""
    Hi <%= invited_user.fullname %>,

    You've been invited by <%= invited_user.invited_by_user_id %>. Please use the following link to accept your invitation:

    <%= content_tag(:p, link(@url, to: @url)) %>

    """
  end
end
