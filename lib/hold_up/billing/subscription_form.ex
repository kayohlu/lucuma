# defmodule HoldUp.Billing.SubscriptionForm do
#   @moduledoc """
#   This is an embedded schema (i.e. virtual schema) to allow  us to work with forms that span many actual schemas (DB tables)
#   http://blog.plataformatec.com.br/2016/05/ectos-insert_all-and-schemaless-queries/
#   """
#   use Ecto.Schema
#   import Ecto.Changeset

#   embedded_schema do
#     field :id, :string
#     field :stripeToken, :string
#   end

#   def changeset(subscription_form, attrs) do
#     subscription_form
#     |> cast(attrs, [:id, :stripeToken])
#     |> validate_required([:id, :stripeToken])
#   end
# end
