defmodule HoldUp.Accounts.UserBusiness do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_businesses" do
    belongs_to :user, HoldUp.Accounts.User
    belongs_to :business, HoldUp.Accounts.Business

    timestamps()
  end

  @doc false
  def changeset(user_business, attrs) do
    user_business
    |> cast(attrs, [
      :user_id,
      :business_id
    ])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:business_id)
    |> validate_required([:user_id, :business_id])
  end
end
