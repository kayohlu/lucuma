defmodule HoldUpWeb.Features.InvitationTest do
  use HoldUp.FeatureCase, async: false

  import HoldUp.Factory
  import Wallaby.Query

  describe "when thee user opens the invitation link and enters their details to register" do
    test "the user registers successfully", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, roles: ["company_admin"])
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      invited_user =
        insert(:user,
          invited_by_id: user.id,
          inviter: user,
          company: company,
          roles: ["staff"],
          invitation_expiry_at: Timex.shift(Timex.now(), days: 4) |> DateTime.truncate(:second)
        )

      insert(:user_business, user_id: invited_user.id, business_id: business.id)

      invitation_url =
        HoldUpWeb.Router.Helpers.invitations_url(
          HoldUpWeb.Endpoint,
          :show,
          invited_user.invitation_token
        )

      page =
        session
        |> visit(invitation_url)
        |> fill_in(text_field("invitation[password]"), with: "123123123")
        |> fill_in(text_field("invitation[password_confirmation]"), with: "123123123")
        |> click(button("Accept Invite"))

      assert_text(page, "Invitation accepted successfully")
    end
  end

  describe "when the user opens the invitation link to find their invite has expired" do
    test "the user sees that it has expired", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company, roles: ["company_admin"])
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      invited_user =
        insert(:user,
          invited_by_id: user.id,
          inviter: user,
          company: company,
          roles: ["staff"],
          invitation_expiry_at: Timex.shift(Timex.now(), days: -5) |> DateTime.truncate(:second)
        )

      insert(:user_business, user_id: invited_user.id, business_id: business.id)

      invitation_url =
        HoldUpWeb.Router.Helpers.invitations_url(
          HoldUpWeb.Endpoint,
          :show,
          invited_user.invitation_token
        )

      page =
        session
        |> visit(invitation_url)

      assert_text(page, "Invitation expired")
    end
  end
end
