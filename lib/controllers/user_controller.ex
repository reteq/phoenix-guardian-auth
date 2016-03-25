defmodule PhoenixGuardianAuth.UserController do
  use Phoenix.Controller

  require Ecto.Query
  import PhoenixGuardianAuth.Controller

  alias PhoenixTokenAuth.{Mailer, Util, UserHelper, AccountUpdater, Registrator, Confirmator, Authenticator, PasswordResetter}
  alias GuardianDb.Token

  @activator Application.get_env(:phoenix_guardian_auth, :activator, Mailer)
  @user_behaviour Application.get_env(:phoenix_guardian_auth, :user_behaviour, PhoenixGuardianAuth.DefaultUserBehaviour)

  def unauthenticated(_conn, _params) do
    raise Necta.AuthException, message: "Not Authenticated"
  end

  @doc """
  Sign up as a new user.

  Params should be:
      {user: {email: "user@example.com", password: "secret"}}

  If successfull, sends a welcome email.

  Responds with status 200 and body "ok" if successfull.
  Responds with status 422 and body {errors: {field: "message"}} otherwise.
  """
  def create(conn, %{"data" => %{"attributes" => params}}) do
    {confirmation_token, changeset} = Registrator.changeset(params)
    |> Confirmator.confirmation_needed_changeset

    Util.repo.transaction fn ->
      user = Util.repo.insert!(changeset)
      @activator.send_welcome(user, confirmation_token, conn)
      @user_behaviour.created(conn, user)
    end
  end

  @doc """
  Confirm either a new user or an existing user's new email address.

  Parameter "id" should be the user's id.
  Parameter "confirmation" should be the user's confirmation token.

  If the confirmation matches, the user will be confirmed and signed in.

  Responds with status 200 and body {token: token} if successfull. Use this token in subsequent requests as authentication.
  Responds with status 422 and body {errors: {field: "message"}} otherwise.
  """
  def confirm(conn, %{"data" => %{"attributes" => params = %{"id" => user_id, "confirmation_token" => _}}}) do
    user = Util.repo.get! UserHelper.model, user_id
    changeset = Confirmator.confirmation_changeset user, params

    Util.repo.transaction fn ->
      user = Util.repo.update!(changeset)
      @user_behaviour.confirmed(conn, user)
    end
  end

  def confirm_with_get(conn, params = %{"id" => _user_id, "confirmation_token" => _}) do
    confirm(conn, %{"data" => %{"attributes" => params}})
  end

  @doc """
  Log in as an existing user.

  Parameter are "email" and "password".

  Responds with status 200 and {token: token} if credentials were correct.
  Responds with status 401 and {errors: error_message} otherwise.
  """
  def login(conn, %{"data" => %{"attributes" => %{"email" => email, "password" => password}}}) do
    Util.repo.transaction fn ->
      {:ok, user} = Authenticator.authenticate_by_email(email, password)
      @user_behaviour.signed_in(conn, user)
    end
  end

  def login(conn, %{"data" => %{"attributes" => %{"account" => account, "password" => password}}}) do
    Util.repo.transaction fn ->
      {:ok, user} = Authenticator.authenticate_by_account(account, password)
      @user_behaviour.signed_in(conn, user)
    end
  end

  @doc """
  Destroy the active session.
  Will delete the authentication token from the user table.

  Responds with status 200 if no error occured.
  """
  def logout(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    {:ok, claims} = Guardian.Plug.claims(conn)

    Util.repo.transaction fn ->
      user = current_user(conn)
      Guardian.revoke!(jwt, claims)
      @user_behaviour.signed_out(conn, user)
    end
  end

  @doc """
  Create a password reset token for a user

  Params should be:
      {email: "user@example.com"}

  If successfull, sends an email with instructions on how to reset the password.

  Responds with status 200 and body "ok" if successfull.
  Responds with status 422 and body {errors: [messages]} otherwise.
  """
  def request_reset(conn, %{"data" => %{"attributes" => %{"email" => email}}}) do
    user = UserHelper.find_by_email(email)
    {password_reset_token, changeset} = PasswordResetter.create_changeset(user)

    Util.repo.transaction fn ->
      user = Util.repo.update!(changeset)
      @activator.send_password_reset(user, password_reset_token, conn)
      @user_behaviour.requested_reset(conn, user)
    end
  end

  def request_reset(conn, %{"data" => %{"attributes" => %{"account" => account}}}) do
    user = UserHelper.find_by_account(account)
    {password_reset_token, changeset} = PasswordResetter.create_changeset(user)

    Util.repo.transaction fn ->
      user = Util.repo.update!(changeset)
      @activator.send_password_reset(user, password_reset_token, conn)
      @user_behaviour.requested_reset(conn, user)
    end
  end

  @doc """
  Resets a users password if the provided token matches

  Params should be:
      {user_id: 1, password_reset_token: "abc123"}

  Responds with status 200 and body {token: token} if successfull. Use this token in subsequent requests as authentication.
  Responds with status 422 and body {errors: [messages]} otherwise.
  """
  def confirm_reset(conn, %{"data" => %{"attributes" => params = %{"id" => user_id}}}) do
    user = Util.repo.get(UserHelper.model, user_id)
    changeset = PasswordResetter.reset_changeset(user, params)

    {:ok, conned} = Util.repo.transaction fn ->
      user = Util.repo.update!(changeset)
      {:ok, sub} = Guardian.serializer.for_token(user)
      Ecto.Query.from(t in Token, where: t.sub == ^sub and t.typ == "token") |> GuardianDb.repo.delete_all
      @user_behaviour.confirmed_reset(conn, user)
    end

    conned
  end

  def confirm_reset_with_get(conn, params = %{"id" => _user_id, "password_reset_token" => _}) do
    confirm_reset(conn, %{"data" => %{"attributes" => params}})
  end

  @doc """
  Update email address and password of the current user.
  If the email address should be updated, the user will receive an email to his new address.
  The stored email address will only be updated after clicking the link in that message.

  Responds with status 200 and body "ok" if successfull.
  """
  def update(conn, %{"data" => %{"attributes" => params}}) do
    {confirmation_token, changeset} = conn
    |> current_user_model
    |> AccountUpdater.changeset(params)

    {:ok, conned} = Util.repo.transaction fn ->
      user = Util.repo.update!(changeset)
      if (confirmation_token != nil) do
        @activator.send_new_account(user, confirmation_token, conn)
      end
      @user_behaviour.updated(conn, user)
    end

    conned
  end

  defp current_user_model(conn) do
    Util.repo.get(UserHelper.model, Guardian.Plug.current_resource(conn).id)
  end

end
