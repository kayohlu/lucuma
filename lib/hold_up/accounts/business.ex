defmodule HoldUp.Accounts.Business do
  use Ecto.Schema
  import Ecto.Changeset

  schema "businesses" do
    field :name, :string

    belongs_to :company, HoldUp.Accounts.Company
    many_to_many :users, HoldUp.Accounts.User, join_through: HoldUp.Accounts.UserBusiness
    has_one :waitlist, HoldUp.Waitlists.Waitlist

    timestamps()
  end

  @doc false
  def changeset(hold_up, attrs) do
    hold_up
    |> cast(attrs, [:name, :company_id])
    |> validate_required([:name, :company_id])
  end
end
