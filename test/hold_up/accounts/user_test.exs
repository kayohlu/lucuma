defmodule HoldUp.AccountsTests.UserTest do
  use HoldUp.DataCase, async: true

  import HoldUp.Factory

  alias HoldUp.Accounts

  describe "users" do
    alias HoldUp.Accounts.User
    alias HoldUp.Accounts.Company

    test "get_user!/1 returns the user with given id" do
      user = insert(:user, company: insert(:company))

      assert Accounts.get_user!(user.id).id == user.id
    end

    test "get_user/1 returns nil with given id when no user with the given id exists" do
      assert Accounts.get_user(1) == nil
    end

    test "create_user/1 with valid data creates a user" do
      company = insert(:company)
      user_params = params_for(:user)

      assert {:ok, %User{} = user} =
               Accounts.create_user(Map.put(user_params, :company_id, company.id))

      assert user.confirmation_sent_at ==
               user_params.confirmation_sent_at |> DateTime.truncate(:second)

      assert user.confirmation_token == user_params.confirmation_token
      assert user.confirmed_at == user_params.confirmed_at |> DateTime.truncate(:second)
      assert user.email == user_params.email
      assert user.full_name == user_params.full_name
      assert user.reset_password_token == user_params.reset_password_token
      assert user.company_id == company.id
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(%{email: nil})
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user, company: insert(:company))
      user_params = params_for(:user)

      assert {:ok, %User{} = user} = Accounts.update_user(user, user_params)

      assert user.confirmation_sent_at ==
               user_params.confirmation_sent_at |> DateTime.truncate(:second)

      assert user.confirmation_token == user_params.confirmation_token
      assert user.confirmed_at == user_params.confirmed_at |> DateTime.truncate(:second)
      assert user.email == user_params.email
      assert user.full_name == user_params.full_name
      assert user.reset_password_token == user_params.reset_password_token
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user, company: insert(:company))

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{email: nil})
      assert user.id == Accounts.get_user!(user.id).id
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user, company: insert(:company))

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user, company: insert(:company))

      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
