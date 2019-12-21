defmodule Lucuma.Accounts.Business do
  use Ecto.Schema
  import Ecto.Changeset

  schema "businesses" do
    field :name, :string

    belongs_to :company, Lucuma.Accounts.Company
    many_to_many :users, Lucuma.Accounts.User, join_through: Lucuma.Accounts.UserBusiness
    has_one :waitlist, Lucuma.Waitlists.Waitlist

    timestamps()
  end

  @doc false
  def changeset(lucuma, attrs) do
    lucuma
    |> cast(attrs, [:name, :company_id])
    |> validate_required([:name, :company_id])
  end
end
