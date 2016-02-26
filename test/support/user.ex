defmodule PhoenixGuardianAuth.User do
  use Ecto.Model

  schema "users" do
    field :account, :string
    field :hashed_password, :string
    field :hashed_confirmation_token, :string
    field :confirmed_at, Ecto.DateTime
    field :unconfirmed_account, :string
    field :hashed_password_reset_token, :string

    timestamps
  end

  @required_fields ~w(account)
  @optional_fields ~w(hashed_password hashed_confirmation_token confirmed_at unconfirmed_account hashed_password_reset_token)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end