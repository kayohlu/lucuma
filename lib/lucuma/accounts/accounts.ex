defmodule Lucuma.Accounts do
  @moduledoc """
  The Accounts context.
  """

  require Logger

  import Ecto.Query, warn: false

  alias Lucuma.Repo
  alias Lucuma.Accounts.User
  alias Lucuma.Accounts.Company
  alias Lucuma.Accounts.Business
  alias Lucuma.Accounts.UserBusiness

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_business(id), do: Repo.get!(Business, id)

  def get_user(id), do: Repo.get(User, id)

  def get_current_company(%User{} = user), do: Repo.get(Company, user.company_id)

  def get_user_by_invitation(id) do
    query =
      from user in Lucuma.Accounts.User,
        join: company in Lucuma.Accounts.Company,
        on: company.id == user.company_id,
        join: businesses in Lucuma.Accounts.Business,
        on: businesses.company_id == company.id,
        where: user.invitation_token == ^id,
        preload: [company: {company, businesses: businesses}]

    Repo.one(query)
  end

  def list_staff(business) do
    query =
      from user in User,
        join: user_business in Lucuma.Accounts.UserBusiness,
        on: user_business.user_id == user.id,
        where: "staff" in user.roles and user_business.business_id == ^business.id

    Repo.all(query)
  end

  def delete_staff_memeber(user_id) do
    get_user(user_id)
    |> delete_user
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def accept_user_invite(%User{} = user, attrs) do
    attrs = Map.put_new(attrs, "invitation_accepted_at", DateTime.utc_now())

    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_company(%Company{} = company) do
    Company.changeset(company, %{})
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def change_user_profile(%User{} = user) do
    User.profile_changeset(user, %{})
  end

  def change_user_password(%User{} = user) do
    User.password_changeset(user, %{})
  end

  def change_invitation(%User{} = user) do
    User.invitation_changeset(user, %{})
  end

  def create_invited_user(inviting_user, company, business, attrs \\ %{}) do
    user_changeset =
      %User{
        company_id: company.id,
        invited_by_id: inviting_user.id
      }
      |> User.invitation_changeset(attrs)

    multi_result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, user_changeset)
      |> Ecto.Multi.insert(:business, fn previous_steps ->
        UserBusiness.changeset(%UserBusiness{}, %{
          user_id: previous_steps.user.id,
          business_id: business.id
        })
      end)
      |> Repo.transaction()

    case multi_result do
      {:ok, steps} ->
        {:ok, Repo.preload(steps.user, :inviter, force: true)}

      {:error, failed_operation, failed_value, changes_so_far} ->
        Logger.info("User invitation failed.")
        Logger.info(inspect(failed_operation))
        Logger.info(inspect(failed_value))
        Logger.info(inspect(changes_so_far))
        {:error, %{user_changeset | action: :invitation}}
    end
  end

  def user_invitation_expired(user) do
    current_time = DateTime.utc_now()
    user_invitation_expiry_time = user.invitation_expiry_at

    Timex.compare(user_invitation_expiry_time, current_time) in [-1, 0]
  end

  def get_user_by_email(email) do
    query =
      from user in Lucuma.Accounts.User,
        join: company in Lucuma.Accounts.Company,
        where: company.id == user.company_id,
        join: businesses in Lucuma.Accounts.Business,
        where: businesses.company_id == company.id,
        where: user.email == ^email,
        preload: [company: {company, businesses: businesses}]

    Repo.one(query)
  end

  def get_current_business_for_user(user) do
    query =
      from users_businesses in Lucuma.Accounts.UserBusiness,
        join: businesses in Lucuma.Accounts.Business,
        where: businesses.id == users_businesses.business_id,
        where: users_businesses.user_id == ^user.id,
        order_by: users_businesses.id,
        limit: 1,
        preload: [business: businesses]

    Repo.one(query).business
  end

  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def create_business(attrs \\ %{}) do
    %Business{}
    |> Business.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_business(attrs \\ %{}) do
    %UserBusiness{}
    |> UserBusiness.changeset(attrs)
    |> Repo.insert()
  end
end
