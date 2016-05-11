defmodule PhoenixTokenAuth.AccountUpdater do
  alias Ecto.Changeset
  alias PhoenixTokenAuth.{Util, UserHelper, Confirmator}

  @doc """
  Returns confirmation token and changeset updating email and hashed_password on an existing user.
  Validates that email and password are present and that email is unique.
  """
  def changeset(user, params) do
    Changeset.cast(user, params, [])
    |> UserHelper.validator
    |> apply_password_change(params)
    |> apply_account_change(params)
  end

  def apply_email_change(changeset = %{params: %{"email" => email}, data: %{email: email_before}})
    when email != "" and email != nil and email != email_before do
    changeset
    |> Changeset.put_change(:unconfirmed_email, email)
    |> Confirmator.confirmation_needed_changeset
  end
  def apply_email_change(changeset), do: {nil, changeset}

  def apply_account_change(changeset = %{data: %{account: account_before}}, %{"account" => account})
    when account != "" and account != nil and account != account_before do
    changeset
    |> Changeset.put_change(:unconfirmed_account, account)
    |> Confirmator.confirmation_needed_changeset
  end

  def apply_account_change(changeset, _), do: {nil, changeset}

  def apply_password_change(changeset, %{"password" => password}) when password != "" and password != nil do
    hashed_password = Util.crypto_provider.hashpwsalt(password)
    changeset
    |> Changeset.put_change(:hashed_password, hashed_password)
  end
  def apply_password_change(changeset, _), do: changeset
end
