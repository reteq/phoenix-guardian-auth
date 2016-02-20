defmodule PhoenixTokenAuth.Authenticator do
  alias PhoenixTokenAuth.{Util, UserHelper}

  @doc """
  Tries to authenticate a user with the given email and password.

  Returns:
  * {:ok, token} if a confirmed user is found. The token has to be send in the "authorization" header on following requests: "Authorization: Bearer \#{token}"
  * {:error, message} if the user was not confirmed before or no matching user was found
  """
  @unconfirmed_account_error_message "Account not confirmed yet. Please follow the instructions we sent you by email."
  def authenticate_by_email(email, password) do
    user = UserHelper.find_by_email(email)
    authenticate(user, password)
  end
  def authenticate_by_username(username, password) do
    user = UserHelper.find_by_username(username)
    authenticate(user, password)
  end
  def authenticate_by_account(account, password) do
    user = UserHelper.find_by_account(account)
    authenticate(user, password)
  end

  def authenticate(user, password) do
    case check_password(user, password) do
      {:ok, %{confirmed_at: nil}} -> raise PhoenixGuardianAuth.AuthException, message: @unconfirmed_account_error_message
      {:ok, _} -> {:ok, user}
      {:error, error} -> raise PhoenixGuardianAuth.AuthException, message: error.base
    end
  end

  @unknown_password_error_message "Unknown email or password"
  defp check_password(nil, _) do
    Util.crypto_provider.dummy_checkpw
    raise PhoenixGuardianAuth.AuthException, message: @unknown_password_error_message
  end
  defp check_password(user, password) do
    if Util.crypto_provider.checkpw(password, user.hashed_password) do
      {:ok, user}
    else
      raise PhoenixGuardianAuth.AuthException, message: @unknown_password_error_message
    end
  end

end
