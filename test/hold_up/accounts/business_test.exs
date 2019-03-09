defmodule HoldUp.AccountsTests.BusinessTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Accounts

  describe "users" do
    alias HoldUp.Accounts.Business
    alias HoldUp.Accounts.Company

    @valid_attrs %{
      name: "name"
    }
    @update_attrs %{
      name: "name updated"
    }
    @invalid_attrs %{
      name: nil
    }

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        %{
          name: "name",
          contact_email: "test@testcompany.com"
        }
        |> Accounts.create_company()

      company
    end

    def business_fixture(attrs \\ %{}) do
      {:ok, business} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_business()

      business
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

    test "create_business/1 with valid data creates a business" do
      company = company_fixture

      assert {:ok, %Business{} = business} =
               Accounts.create_business(Map.put(@valid_attrs, :company_id, company.id))

      assert business.company_id == company.id
      assert business.name == "name"
    end

    test "create_business/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_business(@invalid_attrs)
    end

    test "get_current_business_for_user/1 returns the business the given user belongs to" do
      company = company_fixture()
      user = user_fixture(%{company_id: company.id})
      business = business_fixture(%{company_id: company.id})

      assert Accounts.get_current_business_for_user(user) == business
    end
  end
end
