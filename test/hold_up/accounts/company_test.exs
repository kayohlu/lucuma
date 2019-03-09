defmodule HoldUp.AccountsTests.CompanyTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Accounts

  describe "companies" do
    alias HoldUp.Accounts.Company

    @valid_attrs %{
      name: "name",
      contact_email: "test@testcompany.com"
    }
    @update_attrs %{
      name: "name updated",
      contact_email: "test_updated@testcompany.com"
    }
    @invalid_attrs %{
      name: nil,
      contact_email: nil
    }

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_company()

      company
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{
          confirmation_sent_at: "2010-04-17T14:00:00Z",
          confirmation_token: "some confirmation_token",
          confirmed_at: "2010-04-17T14:00:00Z",
          email: "some email",
          full_name: "some full_name",
          password_hash: "some password_hash",
          reset_password_token: "some reset_password_token"
        })
        |> Accounts.create_user()

      user
    end

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Accounts.create_company(@valid_attrs)
      assert company.name == "name"
      assert company.contact_email == "test@testcompany.com"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_company(@invalid_attrs)
    end

    test "get_current_company/1 returns the company the given user belongs to" do
      company = company_fixture()
      user = user_fixture(%{company_id: company.id})

      assert Accounts.get_current_company(user) == company
    end
  end
end
