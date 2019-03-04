defmodule HoldUp.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.Registrations.RegistrationForm
  alias HoldUp.Accounts.Company
  alias HoldUp.Accounts.User
  alias HoldUp.Accounts.Business
  alias HoldUp.Waitlists.Waitlist
  alias HoldUp.Waitlists.ConfirmationSmsSetting
  alias HoldUp.Waitlists.AttendanceSmsSetting

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
        {:ok, company} = Repo.insert(company_changeset(registration_form))
        {:ok, user} = Repo.insert(user_changeset(registration_form, company))
        {:ok, business} = Repo.insert(business_changeset(company))
        {:ok, waitlist} = Repo.insert(waitlist_changeset(business))
        {:ok, confirmation_sms_setting} = Repo.insert(confirmation_sms_settings_changeset(waitlist))
        {:ok, attendance_sms_setting} = Repo.insert(attendance_sms_settings_changeset(waitlist))
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
    Company.changeset(%Company{}, %{
      name: registration_form.company_name,
      contact_email: registration_form.email
    })
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
    Business.changeset(%Business{}, %{
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

  defp confirmation_sms_settings_changeset(waitlist) do
    ConfirmationSmsSetting.changeset(%ConfirmationSmsSetting{}, %{
      enabled: true,
      waitlist_id: waitlist.id,
      message_content: """
      Hello [[NAME]],

      It's your turn!

      Regards,
      Your friendly staff
      """
    })
  end

  defp attendance_sms_settings_changeset(waitlist) do
    AttendanceSmsSetting.changeset(%AttendanceSmsSetting{}, %{
      enabled: true,
      waitlist_id: waitlist.id,
      message_content: """
      Hello [[NAME]],

      You've been added to our waitlist. We'll let you know when it's your turn as soon as possible.

      Regards,
      Your friendly staff
      """
    })
  end
end
