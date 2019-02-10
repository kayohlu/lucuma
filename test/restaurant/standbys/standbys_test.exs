defmodule HoldUp.StandbysTest do
  use HoldUp.DataCase

  alias HoldUp.Standbys

  describe "stand_bys" do
    alias HoldUp.Standbys.StandBy

    @valid_attrs %{contact_phone_number: "some contact_phone_number", estimated_wait_time: 42, name: "some name", notes: "some notes", party_size: 42}
    @update_attrs %{contact_phone_number: "some updated contact_phone_number", estimated_wait_time: 43, name: "some updated name", notes: "some updated notes", party_size: 43}
    @invalid_attrs %{contact_phone_number: nil, estimated_wait_time: nil, name: nil, notes: nil, party_size: nil}

    def stand_by_fixture(attrs \\ %{}) do
      {:ok, stand_by} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Standbys.create_stand_by()

      stand_by
    end

    test "list_stand_bys/0 returns all stand_bys" do
      stand_by = stand_by_fixture()
      assert Standbys.list_stand_bys() == [stand_by]
    end

    test "get_stand_by!/1 returns the stand_by with given id" do
      stand_by = stand_by_fixture()
      assert Standbys.get_stand_by!(stand_by.id) == stand_by
    end

    test "create_stand_by/1 with valid data creates a stand_by" do
      assert {:ok, %StandBy{} = stand_by} = Standbys.create_stand_by(@valid_attrs)
      assert stand_by.contact_phone_number == "some contact_phone_number"
      assert stand_by.estimated_wait_time == 42
      assert stand_by.name == "some name"
      assert stand_by.notes == "some notes"
      assert stand_by.party_size == 42
    end

    test "create_stand_by/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Standbys.create_stand_by(@invalid_attrs)
    end

    test "update_stand_by/2 with valid data updates the stand_by" do
      stand_by = stand_by_fixture()
      assert {:ok, %StandBy{} = stand_by} = Standbys.update_stand_by(stand_by, @update_attrs)
      assert stand_by.contact_phone_number == "some updated contact_phone_number"
      assert stand_by.estimated_wait_time == 43
      assert stand_by.name == "some updated name"
      assert stand_by.notes == "some updated notes"
      assert stand_by.party_size == 43
    end

    test "update_stand_by/2 with invalid data returns error changeset" do
      stand_by = stand_by_fixture()
      assert {:error, %Ecto.Changeset{}} = Standbys.update_stand_by(stand_by, @invalid_attrs)
      assert stand_by == Standbys.get_stand_by!(stand_by.id)
    end

    test "delete_stand_by/1 deletes the stand_by" do
      stand_by = stand_by_fixture()
      assert {:ok, %StandBy{}} = Standbys.delete_stand_by(stand_by)
      assert_raise Ecto.NoResultsError, fn -> Standbys.get_stand_by!(stand_by.id) end
    end

    test "change_stand_by/1 returns a stand_by changeset" do
      stand_by = stand_by_fixture()
      assert %Ecto.Changeset{} = Standbys.change_stand_by(stand_by)
    end
  end
end
