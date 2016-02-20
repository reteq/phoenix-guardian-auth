defmodule PhoenixGuardianAuth.GuardianSerializer do
  
  @behaviour Guardian.Serializer

  alias PhoenixTokenAuth.{Util, UserHelper}

  def for_token(user), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, Util.repo.get(UserHelper.model, id) }
  def from_token(_), do: { :error, "Unknown resource type" }

end