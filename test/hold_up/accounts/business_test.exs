defmodule HoldUp.AccountsTests.BusinessTest do
  use HoldUp.DataCase, async: true

  import HoldUp.Factory

  alias HoldUp.Accounts

  describe "users" do
    alias HoldUp.Accounts.Business
    alias HoldUp.Accounts.Company

    test "create_business/1 with valid data creates a business" do
      company = insert(:company)
      business_params = params_for(:business)

      assert {:ok, %Business{} = business} =
               Accounts.create_business(Map.put(business_params, :company_id, company.id))

      assert business.company_id == company.id
      assert business.name == business_params.name
    end

    test "create_business/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_business(%{name: nil})
    end

    test "get_current_business_for_user/1 returns the business the given user belongs to" do
      company = insert(:company)
      user = insert(:user, company: company)
      business = insert(:business, company: company)

      assert Accounts.get_current_business_for_user(user).id == business.id
    end
  end
end
