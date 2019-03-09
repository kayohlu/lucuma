defmodule HoldUp.WaitlistsTests.StandByTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Waitlists
  alias HoldUp.Accounts

  defmodule NotificationsMock do
    def send_sms_notification(_arg1, _arg2, _arg3) do
      send(self(), :send_sms_notification)
    end
  end

  describe "stand_bys" do
    alias HoldUp.Waitlists.StandBy

    @valid_attrs %{
      contact_phone_number: "+353851761516",
      estimated_wait_time: 42,
      name: "some name",
      notes: "some notes",
      party_size: 42
    }
    @update_attrs %{
      contact_phone_number: "+353851761516",
      estimated_wait_time: 43,
      name: "some updated name",
      notes: "some updated notes",
      party_size: 43
    }
    @invalid_attrs %{
      contact_phone_number: nil,
      estimated_wait_time: nil,
      name: nil,
      notes: nil,
      party_size: nil
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
        |> Enum.into(%{
          name: "business 1",
          company_id: company_fixture.id
        })
        |> Accounts.create_business()

      business
    end

    def waitlist_fixture(attrs \\ %{}) do
      {:ok, waitlist} =
        attrs
        |> Enum.into(%{
          name: "asdasd",
          business_id: business_fixture.id
        })
        |> Waitlists.create_waitlist()

      waitlist
    end

    def stand_by_fixture(attrs \\ %{}) do
      {:ok, stand_by} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Waitlists.create_stand_by(NotificationsMock)

      stand_by
    end

    test "get_stand_by!/1 returns the stand_by with given id" do
      waitlist = waitlist_fixture

      stand_by = stand_by_fixture(%{waitlist_id: waitlist.id})
      assert Waitlists.get_stand_by!(stand_by.id) == stand_by
    end

    test "create_stand_by/2 with valid data creates a stand_by" do
      waitlist = waitlist_fixture()

      assert {:ok, %StandBy{} = stand_by} =
               Waitlists.create_stand_by(
                 Map.put(@valid_attrs, :waitlist_id, waitlist.id),
                 NotificationsMock
               )

      assert stand_by.contact_phone_number == "+353851761516"
      assert stand_by.estimated_wait_time == 42
      assert stand_by.name == "some name"
      assert stand_by.notes == "some notes"
      assert stand_by.party_size == 42
      assert_received :send_sms_notification
    end

    test "create_stand_by/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlists.create_stand_by(@invalid_attrs)
    end

    test "update_stand_by/2 with valid data updates the stand_by" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})
      assert {:ok, %StandBy{} = stand_by} = Waitlists.update_stand_by(stand_by, @update_attrs)
      assert stand_by.contact_phone_number == "+353851761516"
      assert stand_by.estimated_wait_time == 43
      assert stand_by.name == "some updated name"
      assert stand_by.notes == "some updated notes"
      assert stand_by.party_size == 43
    end

    test "update_stand_by/2 with invalid data returns error changeset" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})
      assert {:error, %Ecto.Changeset{}} = Waitlists.update_stand_by(stand_by, @invalid_attrs)
      assert stand_by == Waitlists.get_stand_by!(stand_by.id)
    end

    test "delete_stand_by/1 deletes the stand_by" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})
      assert {:ok, %StandBy{}} = Waitlists.delete_stand_by(stand_by)
      assert_raise Ecto.NoResultsError, fn -> Waitlists.get_stand_by!(stand_by.id) end
    end

    test "change_stand_by/1 returns a stand_by changeset" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})
      assert %Ecto.Changeset{} = Waitlists.change_stand_by(stand_by)
    end

    test "notify_stand_by/3 populates the notified_at column on the stand by and sends a notification" do
      waitlist = waitlist_fixture
      stand_by = stand_by_fixture(%{waitlist_id: waitlist.id})

      assert {:ok, %StandBy{} = updated_stand_by} =
               Waitlists.notify_stand_by(waitlist.id, stand_by.id, NotificationsMock)

      assert !is_nil(updated_stand_by.notified_at)
      assert updated_stand_by.id == stand_by.id
      assert_received(:send_sms_notification)
    end

    test "mark_as_attended/1 populates the attended_at column" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:ok, %StandBy{} = updated_stand_by} = Waitlists.mark_as_attended(stand_by.id)
      assert updated_stand_by.id == stand_by.id
      assert !is_nil(updated_stand_by.attended_at)
    end

    test "mark_as_no_show/1 populates the no_show_at column" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:ok, %StandBy{} = updated_stand_by} = Waitlists.mark_as_no_show(stand_by.id)
      assert updated_stand_by.id == stand_by.id
      assert !is_nil(updated_stand_by.no_show_at)
    end

    test "mark_as_cancelled/1 populates the cancelled_at column" do
      stand_by = stand_by_fixture(%{waitlist_id: waitlist_fixture.id})

      assert {:ok, %StandBy{} = updated_stand_by} = Waitlists.mark_as_cancelled(stand_by.cancellation_uuid)
      assert updated_stand_by.id == stand_by.id
      assert !is_nil(updated_stand_by.cancelled_at)
    end
  end
end
