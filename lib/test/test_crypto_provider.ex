defmodule PhoenixGuardianAuth.TestCryptoProvider do
  def hashpwsalt(password) do
    "secret" <> password
  end

  def checkpw(password, "secret" <> password ) when is_binary(password), do: true
  def checkpw(_password, _hash), do: false

  def dummy_checkpw, do: :ok

end