defmodule Restaurant.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias Restaurant.Repo

  alias Restaurant.Registrations.RegistrationForm

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
        {:ok, company} = Repo.insert(company_map(registration_form))
        Repo.insert(restaurant_map(company))
        {:ok, user} = Repo.insert(user_map(registration_form))
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


  defp company_map(registration_form) do
    %Restaurant.Registrations.Company{
      name: registration_form.company_name,
      contact_email: registration_form.email
    }
  end

  defp user_map(registration_form) do
    %Restaurant.Registrations.User{
      email: registration_form.email,
      full_name: registration_form.full_name,
      password_hash: Comeonin.Bcrypt.hashpwsalt(registration_form.password)
    }
  end

  defp restaurant_map(parent_company) do
    %Restaurant.Registrations.Restaurant{
      name: "Unnamed Restaurant",
      company_id: parent_company.id
    }
  end
end
