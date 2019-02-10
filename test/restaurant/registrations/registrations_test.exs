defmodule HoldUp.RegistrationsTest do
  use HoldUp.DataCase

  alias HoldUp.Registrations

  describe "users" do
    alias HoldUp.Registrations.Registration

    @valid_attrs %{email: "some email", full_name: "some full_name", password: "some password", password_confirmation: "some password_confirmation"}
    @update_attrs %{email: "some updated email", full_name: "some updated full_name", password: "some updated password", password_confirmation: "some updated password_confirmation"}
    @invalid_attrs %{email: nil, full_name: nil, password: nil, password_confirmation: nil}

    def registration_fixture(attrs \\ %{}) do
      {:ok, registration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Registrations.create_registration()

      registration
    end

    test "list_users/0 returns all users" do
      registration = registration_fixture()
      assert Registrations.list_users() == [registration]
    end

    test "get_registration!/1 returns the registration with given id" do
      registration = registration_fixture()
      assert Registrations.get_registration!(registration.id) == registration
    end

    test "create_registration/1 with valid data creates a registration" do
      assert {:ok, %Registration{} = registration} = Registrations.create_registration(@valid_attrs)
      assert registration.email == "some email"
      assert registration.full_name == "some full_name"
      assert registration.password == "some password"
      assert registration.password_confirmation == "some password_confirmation"
    end

    test "create_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Registrations.create_registration(@invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{} = registration} = Registrations.update_registration(registration, @update_attrs)
      assert registration.email == "some updated email"
      assert registration.full_name == "some updated full_name"
      assert registration.password == "some updated password"
      assert registration.password_confirmation == "some updated password_confirmation"
    end

    test "update_registration/2 with invalid data returns error changeset" do
      registration = registration_fixture()
      assert {:error, %Ecto.Changeset{}} = Registrations.update_registration(registration, @invalid_attrs)
      assert registration == Registrations.get_registration!(registration.id)
    end

    test "delete_registration/1 deletes the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{}} = Registrations.delete_registration(registration)
      assert_raise Ecto.NoResultsError, fn -> Registrations.get_registration!(registration.id) end
    end

    test "change_registration/1 returns a registration changeset" do
      registration = registration_fixture()
      assert %Ecto.Changeset{} = Registrations.change_registration(registration)
    end
  end
end
