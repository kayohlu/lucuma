defmodule LucumaWeb.Features.StaffTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  test "the staff page lists the staff members for the current business only", %{session: session} do
    company = insert(:company)
    business = insert(:business, company: company)
    user = insert(:user, company: company, roles: ["company_admin"])
    user_business = insert(:user_business, user_id: user.id, business_id: business.id)
    waitlist = insert(:waitlist, business: business)
    insert(:confirmation_sms_setting, waitlist: waitlist)
    insert(:attendance_sms_setting, waitlist: waitlist)

    # another staff user in another business within the parent company
    another_business = insert(:business, company: company)
    another_user_in_another_business = insert(:user, company: company, roles: ["staff"])

    user_business =
      insert(:user_business,
        user_id: another_user_in_another_business.id,
        business_id: another_business.id
      )

    # Staff user
    staff_user = insert(:user, company: company, roles: ["staff"])
    staff_user_business = insert(:user_business, user_id: staff_user.id, business_id: business.id)

    page =
      session
      |> visit("/")
      |> click(link("Sign In"))
      |> fill_in(text_field("Email"), with: user.email)
      |> fill_in(text_field("Password"), with: "123123123")
      |> click(button("Sign In"))

    assert_text(page, "Today")

    page
    |> find(css("#dropdownMenuButton", count: 1))
    |> Wallaby.Element.click()

    page
    |> click(link("Settings"))
    |> click(link("Staff"))

    page
    |> has?(link("Add Staff Member"))

    assert_text(page, "Staff")
    assert_text(page, staff_user.full_name)
    refute_has(page, Query.text(another_user_in_another_business.full_name))
  end

  test "the staff page allows you to add a staff member", %{session: session} do
    company = insert(:company)
    business = insert(:business, company: company)
    user = insert(:user, company: company, roles: ["company_admin"])
    user_business = insert(:user_business, user_id: user.id, business_id: business.id)
    waitlist = insert(:waitlist, business: business)
    insert(:confirmation_sms_setting, waitlist: waitlist)
    insert(:attendance_sms_setting, waitlist: waitlist)

    invited_user = build(:user, invited_by_id: user.id, inviter: user)

    page =
      session
      |> visit("/")
      |> click(link("Sign In"))
      |> fill_in(text_field("Email"), with: user.email)
      |> fill_in(text_field("Password"), with: "123123123")
      |> click(button("Sign In"))

    assert_text(page, "Today")

    page
    |> find(css("#dropdownMenuButton", count: 1))
    |> Wallaby.Element.click()

    page
    |> click(link("Settings"))
    |> click(link("Staff"))

    page
    |> has?(link("Add Staff Member"))

    page
    |> click(link("Add Staff Member"))
    |> fill_in(text_field("Email"), with: invited_user.email)
    |> fill_in(text_field("Full name"), with: "user")
    |> click(button("Invite"))

    # expect staff user to have been created and associated with the current company and current business
    query =
      from user in Lucuma.Accounts.User,
        join: user_business in Lucuma.Accounts.UserBusiness,
        on: user_business.user_id == user.id,
        where: "staff" in user.roles and user_business.business_id == ^business.id

    staff_user = Repo.one(query)

    assert staff_user.company_id == company.id

    page
    |> has?(link("Add Staff Member"))

    assert_text(page, "Staff")
    assert_text(page, staff_user.full_name)
  end

  test "the staff page allows you to remove a staff member", %{session: session} do
    company = insert(:company)
    business = insert(:business, company: company)
    user = insert(:user, company: company, roles: ["company_admin"])
    user_business = insert(:user_business, user_id: user.id, business_id: business.id)
    waitlist = insert(:waitlist, business: business)
    insert(:confirmation_sms_setting, waitlist: waitlist)
    insert(:attendance_sms_setting, waitlist: waitlist)

    # Staff user
    staff_user = insert(:user, company: company, roles: ["staff"])
    staff_user_business = insert(:user_business, user_id: staff_user.id, business_id: business.id)

    page =
      session
      |> visit("/")
      |> click(link("Sign In"))
      |> fill_in(text_field("Email"), with: user.email)
      |> fill_in(text_field("Password"), with: "123123123")
      |> click(button("Sign In"))

    assert_text(page, "Today")

    page
    |> find(css("#dropdownMenuButton", count: 1))
    |> Wallaby.Element.click()

    page
    |> click(link("Settings"))
    |> click(link("Staff"))

    page
    |> has?(link("Add Staff Member"))

    assert_text(page, "Staff")
    assert_text(page, staff_user.full_name)

    alert_message =
      accept_alert(page, fn page ->
        click(page, css(".fas.fa-trash"))
      end)

    page
    |> take_screenshot
    |> find(Wallaby.Query.text("Staff", count: 2))

    assert_text(page, "Staff")
    refute_has(page, Query.text(staff_user.full_name))

    query =
      from user in Lucuma.Accounts.User,
        join: user_business in Lucuma.Accounts.UserBusiness,
        on: user_business.user_id == user.id,
        where: "staff" in user.roles and user_business.business_id == ^business.id

    assert Repo.one(query) == nil
  end
end
