defmodule Restaurant.WaitListsTest do
  use Restaurant.DataCase

  alias Restaurant.WaitLists

  describe "wait_lists" do
    alias Restaurant.WaitLists.WaitList

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def wait_list_fixture(attrs \\ %{}) do
      {:ok, wait_list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> WaitLists.create_wait_list()

      wait_list
    end

    test "list_wait_lists/0 returns all wait_lists" do
      wait_list = wait_list_fixture()
      assert WaitLists.list_wait_lists() == [wait_list]
    end

    test "get_wait_list!/1 returns the wait_list with given id" do
      wait_list = wait_list_fixture()
      assert WaitLists.get_wait_list!(wait_list.id) == wait_list
    end

    test "create_wait_list/1 with valid data creates a wait_list" do
      assert {:ok, %WaitList{} = wait_list} = WaitLists.create_wait_list(@valid_attrs)
      assert wait_list.name == "some name"
    end

    test "create_wait_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WaitLists.create_wait_list(@invalid_attrs)
    end

    test "update_wait_list/2 with valid data updates the wait_list" do
      wait_list = wait_list_fixture()
      assert {:ok, %WaitList{} = wait_list} = WaitLists.update_wait_list(wait_list, @update_attrs)
      assert wait_list.name == "some updated name"
    end

    test "update_wait_list/2 with invalid data returns error changeset" do
      wait_list = wait_list_fixture()
      assert {:error, %Ecto.Changeset{}} = WaitLists.update_wait_list(wait_list, @invalid_attrs)
      assert wait_list == WaitLists.get_wait_list!(wait_list.id)
    end

    test "delete_wait_list/1 deletes the wait_list" do
      wait_list = wait_list_fixture()
      assert {:ok, %WaitList{}} = WaitLists.delete_wait_list(wait_list)
      assert_raise Ecto.NoResultsError, fn -> WaitLists.get_wait_list!(wait_list.id) end
    end

    test "change_wait_list/1 returns a wait_list changeset" do
      wait_list = wait_list_fixture()
      assert %Ecto.Changeset{} = WaitLists.change_wait_list(wait_list)
    end
  end
end
