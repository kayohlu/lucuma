defmodule Restaurant.Registrations.Company do
  use Ecto.Schema
  import Ecto.Changeset


  schema "companies" do
    field :contact_email, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :contact_email])
    |> validate_required([:name, :contact_email])
  end
end
