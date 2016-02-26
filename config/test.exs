use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Set a higher stacktrace during test
config :phoenix, :stacktrace_depth, 20

config :phoenix_guardian_auth, PhoenixGuardianAuth.Endpoint,
  url: [host: "localhost"],
  http: [port: 4001],
  server: false,
  root: Path.dirname(__DIR__),
  secret_key_base: "my secret key base",
  render_errors: [accepts: ~w(html json json-api)],
  pubsub: [name: PhoenixGuardianAuth.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix_guardian_auth, PhoenixGuardianAuth.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "phoenix_guardian_auth_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

config :joken, config_module: Guardian.JWT

config :guardian, Guardian,
  hooks: GuardianDb,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT, # optional
  issuer: "PhoenixGuardianAuth.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: to_string(Mix.env),
  serializer: PhoenixGuardianAuth.GuardianSerializer

config :guardian_db, GuardianDb, repo: PhoenixGuardianAuth.Repo

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

config :ja_serializer,
  key_format: :underscored

config :phoenix_guardian_auth,
  user_model: PhoenixGuardianAuth.User,
  repo: PhoenixGuardianAuth.Repo,
  raise_system_error: true,
  email_sender: "myapp@example.com",
  emailing_module: PhoenixGuardianAuth.TestMailing
  
# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false