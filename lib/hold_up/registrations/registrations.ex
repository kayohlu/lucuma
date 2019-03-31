defmodule HoldUp.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.Registrations.RegistrationForm
  alias HoldUp.Accounts
  alias HoldUp.Waitlists

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
        {:ok, company} = create_company(registration_form)
        {:ok, user} = create_user(registration_form, company)
        {:ok, business} = create_business(company)
        IO.inspect user
        IO.inspect business
        {:ok, users_business} = create_user_business(user, business)
        {:ok, waitlist} = create_waitlist(business)
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

  defp create_company(registration_form) do
    Accounts.create_company(%{
      name: registration_form.company_name,
      contact_email: registration_form.email
    })
  end

  defp create_user(registration_form, company) do
    Accounts.create_user(%{
      email: registration_form.email,
      full_name: registration_form.full_name,
      password_hash: Comeonin.Bcrypt.hashpwsalt(registration_form.password),
      company_id: company.id
    })
  end

  defp create_business(parent_company) do
    Accounts.create_business(%{
      name: "Unnamed Business",
      company_id: parent_company.id
    })
  end

  defp create_user_business(user, business) do
    Accounts.create_user_business(%{
      user_id: user.id,
      business_id: business.id
    })
  end

  defp create_waitlist(business) do
    Waitlists.create_waitlist(%{
      name: "Wait List 1",
      business_id: business.id
    })
  end
end
