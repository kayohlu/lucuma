defmodule HoldUp.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.Registrations.RegistrationForm
  alias HoldUp.Registrations.Company
  alias HoldUp.Registrations.User
  alias HoldUp.Registrations.Waitlist
  alias HoldUp.Registrations.SmsSetting

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
        {:ok, business} = Repo.insert(business_changeset(company))
        {:ok, waitlist} = Repo.insert(waitlist_changeset(business))
        {:ok, sms_settings} = Repo.insert(sms_settings_changeset(waitlist))
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

  defp business_changeset(parent_company) do
    HoldUp.Registrations.Business.changeset(%HoldUp.Registrations.Business{}, %{
      name: "Unnamed Business",
      company_id: parent_company.id
    })
  end

  defp waitlist_changeset(business) do
    Waitlist.changeset(%Waitlist{}, %{
      name: "Wait List 1",
      business_id: business.id
    })
  end

  defp sms_settings_changeset(waitlist) do
    SmsSetting.changeset(%SmsSetting{}, %{
      waitlist_id: waitlist.id,
      message_content: """
      Hello Guest,

      It's your turn!

      Regards,
      Your friendly staff
      """
    })
  end
end
