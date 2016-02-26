defmodule PhoenixGuardianAuth.Factory do
  use ExMachina.Ecto, repo: PhoenixGuardianAuth.Repo

  alias PhoenixGuardianAuth.{User}

  def factory(:user) do
    %User{
      account: "123456",
      hashed_password: "abc123"
    }
  end

  def factory(:confirmed_user) do
    %{build(:user) | confirmed_at: Ecto.DateTime.utc }
  end
  
end