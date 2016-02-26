defmodule PhoenixGuardianAuth.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_guardian_auth

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_phoenix_guardian_auth_key",
    signing_salt: "39NY4VmM"

  plug PhoenixGuardianAuth.Router
end