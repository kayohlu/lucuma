defmodule Restaurant.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias Restaurant.Repo

  alias Restaurant.Registrations.RegistrationForm
  alias Restaurant.Registrations.Company
  alias Restaurant.Registrations.User
  alias Restaurant.Registrations.WaitList

  @doc """
  Creates a registration_form.

  ## Examples

      iex> create_registration_form(%{field: value})
      {:ok, %RegistrationForm{}}

      iex> create_registration_form(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration_form(attrs \\ %{}) do
    changeset = RegistrationForm.changeset(%RegistrationForm{}, attrs)

    if changeset.valid? do
      registration_form = Ecto.Changeset.apply_changes(changeset)

      Repo.transaction(fn ->
        IO.inspect(company_changeset(registration_form))
        {:ok, company} = Repo.insert(company_changeset(registration_form))
        {:ok, user} = Repo.insert(user_changeset(registration_form, company))
        {:ok, restaurant} = Repo.insert(restaurant_changeset(company))
        Repo.insert(waitlist_changeset(restaurant))
        user
      end)
    else
      {:error, %{changeset | action: :registration}}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration_form changes.

  ## Examples

      iex> change_registration_form(registration_form)
      %Ecto.Changeset{source: %RegistrationForm{}}

  """
  def change_registration_form(%RegistrationForm{} = registration_form) do
    RegistrationForm.changeset(registration_form, %{})
  end


  defp company_changeset(registration_form) do
    Company.changeset(%Company{}, %{name: registration_form.company_name, contact_email: registration_form.email})
  end

  defp user_changeset(registration_form, company) do
    User.changeset(%User{}, %{
      email: registration_form.email,
      full_name: registration_form.full_name,
      password_hash: Comeonin.Bcrypt.hashpwsalt(registration_form.password),
      company_id: company.id
    })
  end

  defp restaurant_changeset(parent_company) do
    Restaurant.Registrations.Restaurant.changeset(%Restaurant.Registrations.Restaurant{}, %{
      name: "Unnamed Restaurant",
      company_id: parent_company.id
    })
  end

  defp waitlist_changeset(restaurant) do
    WaitList.changeset(%WaitList{}, %{
      name: "Wait List 1",
      restaurant_id: restaurant.id
    })
  end
end
