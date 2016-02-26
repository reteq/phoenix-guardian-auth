defmodule UsersMigration do
  use Ecto.Migration

  def change do
    # users
    create table(:users) do
      add :account,    :text
      add :hashed_password, :text
      add :hashed_confirmation_token, :text
      add :confirmed_at, :datetime
      add :hashed_password_reset_token, :text
      add :unconfirmed_account,    :text
      timestamps
    end

    create index(:users, [:account], unique: true)

    # guardian db for token storage
    create table(:guardian_tokens, primary_key: false) do
      add :jti, :string, primary_key: true
      add :typ, :string
      add :aud, :string
      add :iss, :string
      add :sub, :string
      add :exp, :bigint
      add :jwt, :text
      add :claims, :map
      timestamps
    end
  end
end

alias PhoenixGuardianAuth.Repo

IO.inspect Ecto.Storage.down(Repo)
IO.inspect Ecto.Storage.up(Repo)
{:ok, _pid} = Repo.start_link
IO.inspect Ecto.Migrator.up(Repo, 0, UsersMigration, log: false)