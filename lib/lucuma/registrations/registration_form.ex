defmodule Lucuma.Registrations.RegistrationForm do
  @moduledoc """
  This is an embedded schema (i.e. virtual schema) to allow  us to work with forms that span many actual schemas (DB tables)
  http://blog.plataformatec.com.br/2016/05/ectos-insert_all-and-schemaless-queries/
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :email, :string
    field :full_name, :string
    field :company_name, :string
    field :password, :string
    field :password_confirmation, :string
  end

  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:email, :full_name, :company_name, :password, :password_confirmation])
    |> validate_required([:email, :full_name, :company_name, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6, max: 32)
    |> validate_confirmation(:password)
  end
end
