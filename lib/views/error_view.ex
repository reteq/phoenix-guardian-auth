defmodule PhoenixGuardianAuth.ErrorView do
  defp to_error(error) do
    PhoenixGuardianAuth.Error.to_error(error)
      |> PhoenixGuardianAuth.ErrorMessageView.format
      |> Poison.encode!
  end

  def template_not_found(_template, %{reason: %{changeset: changeset}}) do
    to_error(changeset)
  end

  def template_not_found(_template, %{reason: reason}) do
    to_error(reason)
  end
end