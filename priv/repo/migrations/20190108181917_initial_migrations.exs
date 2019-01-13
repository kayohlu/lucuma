defmodule Restaurant.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :full_name, :string, null: false
      # authenticatable
      add :password_hash, :string, null: false
      # recoverable
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      # lockable
      add :failed_attempts, :integer, default: 0
      add :unlock_token, :string
      add :locked_at, :utc_datetime
      # trackable
      add :sign_in_count, :integer, default: 0
      add :current_sign_in_at, :utc_datetime
      add :last_sign_in_at, :utc_datetime
      add :current_sign_in_ip, :string
      add :last_sign_in_ip, :string
      # confirmable
      add :confirmation_token, :string
      add :confirmed_at, :utc_datetime
      add :confirmation_sent_at, :utc_datetime
      # rememberable
      add :remember_created_at, :utc_datetime
      timestamps()
    end
    create unique_index(:users, [:email])


    create table(:companies) do
      add :name, :string, null: false
      add :contact_email, :string, null: false

      timestamps()
    end


    create table(:restaurants) do
      add :name, :string, null: false
      add :company_id, references(:companies, on_delete: :nothing), null: false

      timestamps()
    end
    create index(:restaurants, [:company_id])
  end
end