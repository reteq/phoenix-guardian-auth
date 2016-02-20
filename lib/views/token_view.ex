defmodule PhoenixGuardianAuth.TokenView do
  use JaSerializer.PhoenixView

  attributes [:token]

  has_one :user, serializer: PhoenixGuardianAuth.UserView, include: true
end