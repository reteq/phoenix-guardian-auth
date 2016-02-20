defmodule PhoenixGuardianAuth.UserView do
  use JaSerializer.PhoenixView

  location "/api/v1/users/:id"

  attributes [:account]
end