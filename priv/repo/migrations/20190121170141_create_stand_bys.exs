defmodule Restaurant.Repo.Migrations.CreateStandBys do
  use Ecto.Migration

  def change do
    create table(:stand_bys) do
      add :name, :string
      add :contact_phone_number, :string
      add :party_size, :integer
      add :estimated_wait_time, :integer
      add :notes, :string

      timestamps()
    end

  end
end
