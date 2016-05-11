defmodule PhoenixGuardianAuth.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias PhoenixGuardianAuth.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import PhoenixGuardianAuth.Router.Helpers

      # The default endpoint for testing
      @endpoint PhoenixGuardianAuth.Endpoint

      import PhoenixGuardianAuth.ConnCase
    end
  end

  alias PhoenixGuardianAuth.Repo

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(Repo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(Repo, []) end
    :ok
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Repo, [])
    end

    :ok
  end

  @jsonapi "application/vnd.api+json"
  def put_json_api_header(conn) do
    conn
    |> Plug.Conn.put_req_header("accept", @jsonapi)
    |> Plug.Conn.put_req_header("content-type", @jsonapi)
  end
  def put_auth_header(conn, user \\ nil) do
    if user == nil do
      user = Factory.create(:user)
    end

    conn
    |> put_json_api_header
    |> Guardian.Plug.api_sign_in(user)
  end

  defp data_on_body(body) do
    Poison.decode!(body)
  end

  def errors_on_body(body) do
    body |> data_on_body |> errors_on
  end

  def errors_on(data) do
    data["errors"] |> Enum.map(&(&1["source"]["pointer"] |> String.replace_prefix("data/attributes/", "")))
  end

  def error_message(body) do
    data_on_body(body)["message"]
  end
end
