defmodule PhoenixGuardianAuth.ErrorMessageView do
  def format(error = %PhoenixGuardianAuth.Error{}), do: error
end