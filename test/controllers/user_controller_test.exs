defmodule PhoenixGuardianAuth.UserControllerTest do
  use PhoenixGuardianAuth.ConnCase

  import Mock
  import RouterHelper

  alias PhoenixGuardianAuth.{Factory, GuardianSerializer}

  alias PhoenixTokenAuth.{Util, Registrator, Confirmator, AccountUpdater, UserHelper, PasswordResetter, Authenticator}

  @email "user@example.com"
  @password "secret"

  setup tags do
    conn = conn() |> put_req_header("language", "en") |> put_json_api_header

    if tags[:authenticated] do
      user = Factory.create(:confirmed_user, account: @email)
      Factory.create(:user, account: "fun@reteq.com")
      conn = conn |> put_auth_header(user)
      {:ok, %{conn: conn, user: user}}
    else
      {:ok, conn: conn}
    end
  end

  @tag :mock
  test "sign up", %{conn: conn} do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      conn = post conn, user_path(conn, :create, %{data: %{attributes: %{password: @password, account: @email}}})
      assert conn.status == 200

      # fields are set in the db
      user = Util.repo.one UserHelper.model
      assert user.account == @email
      # hashed token is set
      assert !is_nil(user.hashed_confirmation_token)

      mail = :meck.capture(:first, Mailgun.Client, :send_email, :_, 2)

      assert Keyword.fetch!(mail, :to) == @email
      assert Keyword.fetch!(mail, :subject) == "Hello " <> @email
      assert Keyword.fetch!(mail, :from) == "myapp@example.com"
      assert Keyword.fetch!(mail, :text)# == "the_emails_body with language en"
    end
  end

  test "sign up with missing email", %{conn: conn} do
    {_, _, body} = assert_error_sent 422, fn -> 
      post conn, user_path(conn, :create, %{data: %{attributes: %{password: @password}}})
    end
    assert "account" in errors_on_body(body)
  end

  test "sign up with missing password", %{conn: conn} do
    {_, _, body} = assert_error_sent 422, fn -> 
      post conn, user_path(conn, :create, %{data: %{attributes: %{account: @email}}})
    end
    assert "password" in errors_on_body(body)
  end

  test "confirm user with wrong token", %{conn: conn} do
    {_token, changeset} = Registrator.changeset(%{account: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    user = Factory.create(:user, account: @email,
      hashed_password: changeset.changes.hashed_password,
      hashed_confirmation_token: changeset.changes.hashed_confirmation_token)
    {_, _, body} = assert_error_sent 422, fn -> 
      post conn, user_path(conn, :confirm, %{data: %{attributes: %{id: user.id, confirmation_token: "wrong_token"}}})
    end
    assert "confirmation_token" in errors_on_body(body)
  end

  test "confirm a user", %{conn: conn} do
    {token, changeset} = Registrator.changeset(%{account: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    user = Factory.create(:user, account: @email,
      hashed_password: changeset.changes.hashed_password,
      hashed_confirmation_token: changeset.changes.hashed_confirmation_token)
    conn = post conn, user_path(conn, :confirm, %{data: %{attributes: %{id: user.id, confirmation_token: token}}})

    assert conn.status == 200

    %{"data" => %{"attributes" => %{"token" => token}}} = Poison.decode!(conn.resp_body)
    {:ok, token_data} = Guardian.decode_and_verify(token)

    {:ok, u} = GuardianSerializer.from_token(token_data["sub"])
    assert user.id == u.id

    user = Util.repo.get! UserHelper.model, user.id
    assert user.hashed_confirmation_token == nil
    assert user.confirmed_at != nil

    {_, _, body} = assert_error_sent 412, fn -> 
      post conn, user_path(conn, :confirm, %{data: %{attributes: %{id: user.id, confirmation_token: token}}})
    end
    assert "user has been confirmed" == error_message(body)
  end

  test "confirm a user's new email", %{conn: conn} do
    user = Factory.create(:confirmed_user)

    {token, changeset} = AccountUpdater.changeset(user, %{"account" => "new@example.com"})
    user = Util.repo.update!(changeset)

    conn = post conn, user_path(conn, :confirm, %{data: %{attributes: %{id: user.id, confirmation_token: token}}})
    assert conn.status == 200

    %{"data" => %{"attributes" => %{"token" => token}}} = Poison.decode!(conn.resp_body)
    {:ok, token_data} = Guardian.decode_and_verify(token)

    {:ok, u} = GuardianSerializer.from_token(token_data["sub"])
    assert user.id == u.id

    user = Util.repo.get! UserHelper.model, user.id
    assert user.hashed_confirmation_token == nil
    assert user.unconfirmed_account == nil
    assert user.account == "new@example.com"
  end

  test "sign in with unknown email", %{conn: conn} do
    {_, _, body} = assert_error_sent 401, fn -> 
      post conn, user_path(conn, :login, %{data: %{attributes: %{password: @password, account: @email}}})
    end
    assert "Unknown email or password" == error_message(body)
  end

  test "sign in with wrong password", %{conn: conn} do
    {_token, changeset} = Registrator.changeset(%{account: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    Factory.create(:confirmed_user, account: @email,
      hashed_password: changeset.changes.hashed_password)

    {_, _, body} = assert_error_sent 401, fn -> 
      post conn, user_path(conn, :login, %{data: %{attributes: %{password: "wrong", account: @email}}})
    end
    assert "Unknown email or password" == error_message(body)
  end

  test "sign in as unconfirmed user", %{conn: conn} do
    {_token, changeset} = Registrator.changeset(%{account: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    Factory.create(:user, account: @email,
      hashed_password: changeset.changes.hashed_password)

    {_, _, body} = assert_error_sent 401, fn -> 
      post conn, user_path(conn, :login, %{data: %{attributes: %{password: @password, account: @email}}})
    end
    assert "Account not confirmed yet. Please follow the instructions we sent you by email." == error_message(body)
  end

  test "sign in as confirmed user", %{conn: conn} do
    {_token, changeset} = Registrator.changeset(%{account: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    Factory.create(:confirmed_user, account: @email,
      hashed_password: changeset.changes.hashed_password)

    conn = post conn, user_path(conn, :login, %{data: %{attributes: %{password: @password, account: @email}}})
    assert conn.status == 200

    %{"data" => %{"attributes" => %{"token" => token}}} = Poison.decode!(conn.resp_body)

    assert Guardian.decode_and_verify(token)
  end

  @tag :authenticated
  test "sign out as signed in user", %{conn: conn, user: _user} do
    token = Guardian.Plug.current_token(conn)
    delete conn, user_path(conn, :logout)
    assert {:error, :token_not_found} == Guardian.decode_and_verify(token)
  end

  test "request a reset token for an unknown email", %{conn: conn} do
    {_, _, body} = assert_error_sent 422, fn -> 
      post conn, user_path(conn, :request_reset, %{data: %{attributes: %{account: @email}}})
    end
    assert "account" in errors_on_body(body)
  end

  @tag :mock
  test "request a reset token", %{conn: conn} do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      Factory.create(:user, account: @email)
      conn = post conn, user_path(conn, :request_reset, %{data: %{attributes: %{account: @email}}})

      assert conn.status == 200

      user = Util.repo.one UserHelper.model
      assert user.hashed_password_reset_token != nil
    end
  end

  test "reset password with a wrong token", %{conn: conn} do
    {_reset_token, changeset} = Registrator.changeset(%{account: @email, password: "oldpassword"})
    |> PasswordResetter.create_changeset
    user = Factory.create(:user, account: @email, hashed_password_reset_token: changeset.changes.hashed_password_reset_token)
    params = %{data: %{attributes: %{id: user.id, password_reset_token: "wrong_token", password: "newpassword"}}}

    {_, _, body} = assert_error_sent 422, fn -> 
      post conn, user_path(conn, :confirm_reset, params)
    end
    assert "password_reset_token" in errors_on_body(body)
  end

  test "reset password", %{conn: conn} do
    {reset_token, changeset} = Registrator.changeset(%{account: @email, password: "oldpassword"})
    |> PasswordResetter.create_changeset

    user = Factory.create(:user, account: @email, hashed_password_reset_token: changeset.changes.hashed_password_reset_token)

    conn_to_remove = Guardian.Plug.api_sign_in(conn(), user)
    token_to_check = Guardian.Plug.current_token(conn_to_remove)
    assert {:ok, _} = Guardian.decode_and_verify(token_to_check)

    params = %{data: %{attributes: %{id: user.id, password_reset_token: reset_token, password: "newpassword"}}}
    conn = post conn, user_path(conn, :confirm_reset, params)

    assert conn.status == 200

    %{"data" => %{"attributes" => %{"token" => token}}} = Poison.decode!(conn.resp_body)
    {:ok, token_data} = Guardian.decode_and_verify(token)

    {:ok, u} = GuardianSerializer.from_token(token_data["sub"])
    assert user.id == u.id

    # tokens should be removed after reset
    assert {:error, _} = Guardian.decode_and_verify(token_to_check)
  end


  # tests for account update
  @old_email @email
  @new_email "my-new@example.com"
  @old_password @password
  @new_password "whatever"

  @tag :authenticated
  @tag :mock
  test "update password", %{conn: conn, user: _user} do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      conn = put conn, user_path(conn, :update, %{data: %{attributes: %{password: @new_password}}})
      assert conn.status == 200
      {:ok, _} = Authenticator.authenticate_by_account(@old_email, @new_password)

      assert :meck.num_calls(Mailgun.Client, :send_email, :_, 2) == 0
    end
  end

end
