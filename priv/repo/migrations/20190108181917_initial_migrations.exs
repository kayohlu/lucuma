defmodule HoldUp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string, null: false
      add :contact_email, :string, null: false
      add :stripe_customer_id, :string
      add :stripe_payment_plan_id, :string
      add :stripe_subscription_id, :string

      timestamps()
    end

    create table(:businesses) do
      add :name, :string, null: false
      add :company_id, references(:companies, on_delete: :nothing), null: false

      timestamps()
    end
    create index(:businesses, [:company_id])


    create table(:users) do
      add :company_id, references(:companies, on_delete: :nothing), null: false
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

    create table(:users_businesses) do
      add :user_id, references(:users, on_delete: :nothing)
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps()
    end
    create unique_index(:users_businesses, [:user_id, :business_id])


    create table(:waitlists) do
      add :business_id, references(:businesses, on_delete: :nothing)
      add :name, :string
      add :notification_sms_body, :string

      timestamps()
    end
    create index(:waitlists, [:business_id])

    create table(:stand_bys) do
      add :business_id, references(:businesses, on_delete: :nothing)
      add :waitlist_id, references(:waitlists, on_delete: :nothing), null: false
      add :name, :string
      add :contact_phone_number, :string
      add :party_size, :integer
      add :estimated_wait_time, :integer
      add :notes, :string
      add :notified_at, :utc_datetime
      add :attended_at, :utc_datetime
      add :no_show_at, :utc_datetime
      add :cancelled_at, :utc_datetime
      add :cancellation_uuid, :string

      timestamps()
    end
    create index(:stand_bys, [:business_id])
    create index(:stand_bys, [:waitlist_id])

    create table(:confirmation_sms_settings) do
      add :enabled, :boolean
      add :message_content, :string
      add :waitlist_id, references(:waitlists, on_delete: :nothing), null: false

      timestamps()
    end
    create index(:confirmation_sms_settings, [:waitlist_id])
    create table(:attendance_sms_settings) do
      add :enabled, :boolean
      add :message_content, :string
      add :waitlist_id, references(:waitlists, on_delete: :nothing), null: false

      timestamps()
    end
    create index(:attendance_sms_settings, [:waitlist_id])

    create table(:sms_notifications) do
      add :stand_by_id, references(:stand_bys, on_delete: :delete_all)
      add :message_content, :string
      add :recipient_phone_number, :string
      add :status, :string
      add :retries, :integer, default: 0

      timestamps()
    end
    create index(:sms_notifications, [:stand_by_id])
  end
end