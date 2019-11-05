defmodule HoldUp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.UUID

  @invitation_expiry_days 5

  schema "users" do
    field :confirmation_sent_at, :utc_datetime
    field :confirmation_token, :string
    field :confirmed_at, :utc_datetime
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :reset_password_token, :string
    field :roles, {:array, :string}, default: ["company_admin"]
    field :invitation_token, :string
    field :invitation_accepted_at, :utc_datetime
    field :invitation_expiry_at, :utc_datetime

    belongs_to :company, HoldUp.Accounts.Company
    belongs_to :inviter, HoldUp.Accounts.User, foreign_key: :invited_by_id

    many_to_many :businesses, HoldUp.Accounts.Business,
      join_through: HoldUp.Accounts.UserBusiness,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :full_name,
      :password,
      :password_confirmation,
      :password_hash,
      :reset_password_token,
      :confirmation_token,
      :confirmed_at,
      :confirmation_sent_at,
      :company_id,
      :invitation_accepted_at
    ])
    |> unique_constraint(:email, name: "users_email_index")
    |> validate_required([:email, :full_name, :password, :password_confirmation, :company_id])
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6, max: 32)
    |> validate_inclusion(:roles, ["master_admin", "company_admin", "business_admin", "staff"])
    |> clean_email
    |> hash_password()
  end

  def invitation_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :full_name,
      :company_id,
      :invited_by_id
    ])
    |> unique_constraint(:email, name: "users_email_index")
    |> validate_required([:email, :full_name, :company_id, :invited_by_id])
    |> change(%{invitation_token: Ecto.UUID.generate()})
    |> change(%{
      invitation_expiry_at:
        Timex.shift(Timex.now(), days: @invitation_expiry_days) |> DateTime.truncate(:second)
    })
    |> change(%{roles: ["staff"]})
    |> clean_email
  end

  @doc false
  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :full_name
    ])
    |> validate_required([:email])
    |> unique_constraint(:email, name: "users_email_index")
    |> validate_format(:email, ~r/@/)
    |> clean_email
  end

  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :password,
      :password_confirmation
    ])
    |> validate_required([:password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6, max: 32)
    |> hash_password()
  end

  @doc """
  When an invitation is sent and the person clicks the accept invite link
  from their email, it uses the changeset function above for the form.
  So, I have check if the password exists in the changes of the changeset.
  The user can exist without a password_hash in the first place because
  the invitation changeset is used.
  """
  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        hash = Comeonin.Bcrypt.hashpwsalt(password)
        put_change(changeset, :password_hash, hash)
    end
  end

  def clean_email(changeset) do
    changeset
    |> update_change(:email, &String.downcase/1)
    |> update_change(:email, &String.trim/1)
  end
end
