# defmodule Lucuma.Registrations.Registration do
#   use Ecto.Schema
#   import Ecto.Changeset

#   schema do
#     field :email, :string
#     field :full_name, :string
#     field :company_name, :string
#     field :password, :string, virtual: true
#     field :password_confirmation, :string, virtual: true
#     field :time_zone, :string
#     field :registration_expiry_at, :utc_datetime
#   end

#   def changeset(registration, attrs) do
#     registration
#     |> cast(attrs, [
#       :email,
#       :full_name,
#       :company_name,
#       :password,
#       :password_confirmation,
#       :time_zone,
#       :registration_expiry_at,
#       :flow,
#       :step
#     ])
#     |> validate_required([
#       :email,
#       :full_name,
#       :company_name,
#       :password,
#       :password_confirmation,
#       :time_zone,
#       :flow,
#       :step
#     ])
#     |> validate_format(:email, ~r/@/)
#     |> validate_length(:password, min: 6, max: 32)
#     |> validate_confirmation(:password)
#     |> validate_inclusion(:flow, [
#       "only_account_details",
#       "with_subscription",
#     ])
#   end

#   def steps_for_flow(flow) do
#     %{
#       "only_account_details" => ["account_details", "completion"],
#       "with_subscription" => ["account_details", "subscription", "completion"]
#     }
#   end
# end
