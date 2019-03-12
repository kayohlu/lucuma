defmodule HoldUp.AccountsTests.CompanyTest do
  use HoldUp.DataCase, async: true

  import HoldUp.Factory

  alias HoldUp.Accounts

  describe "companies" do
    alias HoldUp.Accounts.Company

    test "create_company/1 with valid data creates a company" do
      company_params = params_for(:company)
      assert {:ok, %Company{} = company} = Accounts.create_company(company_params)
      assert company.name == company_params.name
      assert company.contact_email == company_params.contact_email
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_company(%{name: nil})
    end

    test "get_current_company/1 returns the company the given user belongs to" do
      company = insert(:company)
      user = insert(:user, company: company)

      assert Accounts.get_current_company(user) == company
    end
  end
end
