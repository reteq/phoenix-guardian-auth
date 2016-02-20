defmodule PhoenixGuardianAuth.ErrorMessageView do

  use JaSerializer.PhoenixView

  attributes [:message, :errors]

end