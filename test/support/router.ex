defmodule PhoenixGuardianAuth.Router do
  use Phoenix.Router

  pipeline :json_api do
    plug :accepts, ["json-api"]
    plug JaSerializer.Deserializer
    #plug Necta.ContentTypeNegotiation
  end

  pipeline :authenticated do
    plug Guardian.Plug.VerifyHeader, realm: "Cheq"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: PhoenixGuardianAuth.UserController
  end

  scope "/api/v1/users", PhoenixGuardianAuth do
    pipe_through :json_api

    post "/", UserController, :create
    post "/confirm", UserController, :confirm
    get "/:id/confirm/:confirmation_token", UserController, :confirm_with_get
    post "/login", UserController, :login
    post "/password_resets", UserController, :request_reset
    post "/password_resets/reset", UserController, :confirm_reset
    get "/:id/password_resets/reset/:password_reset_token", UserController, :confirm_reset_with_get
  end

  scope "/api/v1/users", PhoenixGuardianAuth do
    pipe_through :json_api
    pipe_through :authenticated

    delete "/login", UserController, :logout
    put "/", UserController, :update

    # user
    get "/users/", UserController, :index
  end

end

defmodule RouterHelper do
  use Plug.Test

  def call(router, verb, path, params \\ nil, headers \\ []) do
    conn = conn(verb, path, params)
    conn = Enum.reduce(headers, conn, fn ({name, value}, conn) ->
      put_req_header(conn, name, value)
    end)
    conn = Plug.Conn.fetch_query_params(conn)
    router.call(conn, router.init([]))
  end
end