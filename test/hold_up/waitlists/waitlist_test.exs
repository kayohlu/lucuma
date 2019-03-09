defmodule HoldUp.WaitlistsTests.WaitlistTest do
  use HoldUp.DataCase, async: true

  alias HoldUp.Waitlists
  alias HoldUp.Accounts

  defmodule NotificationsMock do
    def send_sms_notification(_arg1, _arg2, _arg3) do
      send(self(), :send_sms_notification)
    end
  end

  describe "waitlists" do
    alias HoldUp.Waitlists.Waitlist

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

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
          name: "waitlist 1",
          business_id: business_fixture.id
        })
        |> Waitlists.create_waitlist()

      waitlist
    end

    def stand_by_fixture(attrs \\ %{}) do
      {:ok, stand_by} =
        attrs
        |> Enum.into(%{
          contact_phone_number: "+353851761516",
          estimated_wait_time: 42,
          name: "some name",
          notes: "some notes",
          party_size: 42
        })
        |> Waitlists.create_stand_by(NotificationsMock)

      stand_by
    end

    test "get_waitlist!/1 returns the waitlist with given id" do
      waitlist = waitlist_fixture(%{business_id: business_fixture.id})
      assert waitlist.id == Waitlists.get_waitlist!(waitlist.id).id
    end

    test "create_waitlist/1 with valid data creates a waitlist" do
      assert {:ok, %Waitlist{} = waitlist} =
               Waitlists.create_waitlist(Map.put(@valid_attrs, :business_id, business_fixture.id))

      assert waitlist.name == "some name"
    end

    test "create_waitlist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlists.create_waitlist(@invalid_attrs)
    end

    test "get_business_waitlist/1 returns the waitlist associated with the given business_id" do
      business = business_fixture
      waitlist = waitlist_fixture(%{business_id: business.id})

      assert waitlist.id == Waitlists.get_business_waitlist(business.id).id
    end

    test "party_size_breakdown/1 returns a map of party size to count" do
      waitlist = waitlist_fixture
      stand_by = stand_by_fixture(%{waitlist_id: waitlist.id})

      assert [%{:name => stand_by.party_size, :y => 1}] ==
               Waitlists.party_size_breakdown(waitlist.id)
    end

    test "calculate_average_wait_time/1 returns the average wait time for today" do
      waitlist = waitlist_fixture
      stand_by = stand_by_fixture(%{
        waitlist_id: waitlist.id,
        notified_at: DateTime.add(DateTime.utc_now, 60, :second)
        })

      assert 1 = Waitlists.calculate_average_wait_time(waitlist.id)
    end
  end
end
