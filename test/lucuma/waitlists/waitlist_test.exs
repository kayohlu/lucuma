defmodule Lucuma.WaitlistsTests.WaitlistTest do
  use Lucuma.DataCase, async: true

  import Lucuma.Factory

  alias Lucuma.Waitlists
  alias Lucuma.Accounts

  describe "waitlists" do
    alias Lucuma.Waitlists.Waitlist

    test "get_waitlist!/1 returns the waitlist with given id" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)
      assert waitlist.id == Waitlists.get_waitlist!(waitlist.id).id
    end

    test "create_waitlist/1 with valid data creates a waitlist" do
      business = insert(:business, company: insert(:company))
      waitlist_params = params_for(:waitlist)

      assert {:ok, %Waitlist{} = waitlist} =
               Waitlists.create_waitlist(Map.put(waitlist_params, :business_id, business.id))

      assert waitlist.name == waitlist_params.name
    end

    test "create_waitlist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlists.create_waitlist(%{name: nil})
    end

    test "party_size_breakdown/1 returns a map of party size to count" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      stand_by = insert(:stand_by, waitlist_id: waitlist.id)

      assert [%{:name => stand_by.party_size, :y => 1}] ==
               Waitlists.party_size_breakdown(waitlist.id)
    end

    test "calculate_average_wait_time/1 returns the average wait time for today" do
      business = insert(:business, company: insert(:company))
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      stand_by =
        insert(:stand_by,
          waitlist_id: waitlist.id,
          notified_at: DateTime.add(DateTime.utc_now(), 60, :second)
        )

      assert 1 = Waitlists.calculate_average_wait_time(waitlist.id)
    end
  end
end
