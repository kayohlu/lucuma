defmodule HoldUp.WaitlistsTest do
  use HoldUp.DataCase

  alias HoldUp.Waitlists

  describe "waitlists" do
    alias HoldUp.Waitlists.Waitlist

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def waitlist_fixture(attrs \\ %{}) do
      {:ok, waitlist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Waitlists.create_waitlist()

      waitlist
    end

    test "list_waitlists/0 returns all waitlists" do
      waitlist = waitlist_fixture()
      assert Waitlists.list_waitlists() == [waitlist]
    end

    test "get_waitlist!/1 returns the waitlist with given id" do
      waitlist = waitlist_fixture()
      assert Waitlists.get_waitlist!(waitlist.id) == waitlist
    end

    test "create_waitlist/1 with valid data creates a waitlist" do
      assert {:ok, %Waitlist{} = waitlist} = Waitlists.create_waitlist(@valid_attrs)
      assert waitlist.name == "some name"
    end

    test "create_waitlist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlists.create_waitlist(@invalid_attrs)
    end

    test "update_waitlist/2 with valid data updates the waitlist" do
      waitlist = waitlist_fixture()
      assert {:ok, %Waitlist{} = waitlist} = Waitlists.update_waitlist(waitlist, @update_attrs)
      assert waitlist.name == "some updated name"
    end

    test "update_waitlist/2 with invalid data returns error changeset" do
      waitlist = waitlist_fixture()
      assert {:error, %Ecto.Changeset{}} = Waitlists.update_waitlist(waitlist, @invalid_attrs)
      assert waitlist == Waitlists.get_waitlist!(waitlist.id)
    end

    test "delete_waitlist/1 deletes the waitlist" do
      waitlist = waitlist_fixture()
      assert {:ok, %Waitlist{}} = Waitlists.delete_waitlist(waitlist)
      assert_raise Ecto.NoResultsError, fn -> Waitlists.get_waitlist!(waitlist.id) end
    end

    test "change_waitlist/1 returns a waitlist changeset" do
      waitlist = waitlist_fixture()
      assert %Ecto.Changeset{} = Waitlists.change_waitlist(waitlist)
    end
  end
end
