defmodule HoldUp.AccountsTest do
  use HoldUp.DataCase

  alias HoldUp.Accounts

  describe "users" do
    alias HoldUp.Accounts.User

    @valid_attrs %{confirmation_sent_at: "2010-04-17T14:00:00Z", confirmation_token: "some confirmation_token", confirmed_at: "2010-04-17T14:00:00Z", email: "some email", full_name: "some full_name", password_hash: "some password_hash", reset_password_token: "some reset_password_token"}
    @update_attrs %{confirmation_sent_at: "2011-05-18T15:01:01Z", confirmation_token: "some updated confirmation_token", confirmed_at: "2011-05-18T15:01:01Z", email: "some updated email", full_name: "some updated full_name", password_hash: "some updated password_hash", reset_password_token: "some updated reset_password_token"}
    @invalid_attrs %{confirmation_sent_at: nil, confirmation_token: nil, confirmed_at: nil, email: nil, full_name: nil, password_hash: nil, reset_password_token: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.confirmation_sent_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user.confirmation_token == "some confirmation_token"
      assert user.confirmed_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user.email == "some email"
      assert user.full_name == "some full_name"
      assert user.password_hash == "some password_hash"
      assert user.reset_password_token == "some reset_password_token"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.confirmation_sent_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user.confirmation_token == "some updated confirmation_token"
      assert user.confirmed_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user.email == "some updated email"
      assert user.full_name == "some updated full_name"
      assert user.password_hash == "some updated password_hash"
      assert user.reset_password_token == "some updated reset_password_token"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
