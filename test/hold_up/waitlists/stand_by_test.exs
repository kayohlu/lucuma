defmodule HoldUp.WaitlistsTests.StandByTest do
  use HoldUp.DataCase, async: true

  import HoldUp.Factory

  alias HoldUp.Waitlists
  alias HoldUp.Accounts

  defmodule NotificationsMock do
    def send_sms_notification(_arg1, _arg2, _arg3) do
      send(self(), :send_sms_notification)
    end
  end

  describe "stand_bys" do
    alias HoldUp.Waitlists.StandBy

    def insert_waitlist do
      waitlist = insert(:waitlist, business: insert(:business, company: insert(:company)))
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)
      waitlist
    end

    test "get_stand_by!/1 returns the stand_by with given id" do
      waitlist = insert_waitlist

      stand_by = insert(:stand_by, waitlist_id: waitlist.id)
      assert Waitlists.get_stand_by!(stand_by.id) == stand_by
    end

    test "create_stand_by/2 with valid data creates a stand_by" do
      waitlist = insert_waitlist
      stand_by_params = params_for(:stand_by)

      assert {:ok, %StandBy{} = stand_by} =
               Waitlists.create_stand_by(
                 Map.put(stand_by_params, :waitlist_id, waitlist.id),
                 NotificationsMock
               )

      assert stand_by.contact_phone_number == stand_by_params.contact_phone_number
      assert stand_by.estimated_wait_time == stand_by_params.estimated_wait_time
      assert stand_by.name == stand_by_params.name
      assert stand_by.notes == stand_by_params.notes
      assert stand_by.party_size == stand_by_params.party_size
      assert_received :send_sms_notification
    end

    test "create_stand_by/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlists.create_stand_by(%{name: nil})
    end

    test "update_stand_by/2 with valid data updates the stand_by" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)
      stand_by_params = params_for(:stand_by)

      assert {:ok, %StandBy{} = stand_by} = Waitlists.update_stand_by(stand_by, stand_by_params)
      assert stand_by.contact_phone_number == stand_by_params.contact_phone_number
      assert stand_by.estimated_wait_time == stand_by_params.estimated_wait_time
      assert stand_by.name == stand_by_params.name
      assert stand_by.notes == stand_by_params.notes
      assert stand_by.party_size == stand_by_params.party_size
    end

    test "update_stand_by/2 with invalid data returns error changeset" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert {:error, %Ecto.Changeset{}} = Waitlists.update_stand_by(stand_by, %{name: nil})
      assert stand_by == Waitlists.get_stand_by!(stand_by.id)
    end

    test "delete_stand_by/1 deletes the stand_by" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert {:ok, %StandBy{}} = Waitlists.delete_stand_by(stand_by)
      assert_raise Ecto.NoResultsError, fn -> Waitlists.get_stand_by!(stand_by.id) end
    end

    test "change_stand_by/1 returns a stand_by changeset" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert %Ecto.Changeset{} = Waitlists.change_stand_by(stand_by)
    end

    test "notify_stand_by/3 populates the notified_at column on the stand by and sends a notification" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert {:ok, %StandBy{} = updated_stand_by} =
               Waitlists.notify_stand_by(stand_by.id, NotificationsMock)

      assert !is_nil(updated_stand_by.notified_at)
      assert updated_stand_by.id == stand_by.id
      assert_received(:send_sms_notification)
    end

    test "mark_as_attended/1 populates the attended_at column" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert {:ok, %StandBy{} = updated_stand_by} = Waitlists.mark_as_attended(stand_by.id)
      assert updated_stand_by.id == stand_by.id
      assert !is_nil(updated_stand_by.attended_at)
    end

    test "mark_as_no_show/1 populates the no_show_at column" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert {:ok, %StandBy{} = updated_stand_by} = Waitlists.mark_as_no_show(stand_by.id)
      assert updated_stand_by.id == stand_by.id
      assert !is_nil(updated_stand_by.no_show_at)
    end

    test "mark_as_cancelled/1 populates the cancelled_at column" do
      waitlist = insert_waitlist
      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert {:ok, %StandBy{} = updated_stand_by} =
               Waitlists.mark_as_cancelled(stand_by.cancellation_uuid)

      assert updated_stand_by.id == stand_by.id
      assert !is_nil(updated_stand_by.cancelled_at)
    end
  end
end
