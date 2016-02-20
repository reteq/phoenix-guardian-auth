defmodule Necta.NotApplicableException do
  defexception [:message, :plug_status]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    status = Keyword.get(opts, :plug_status, 422)

    %__MODULE__{
      message: message,
      plug_status: status
    }
  end
end

defmodule PhoenixGuardianAuth.AuthException do
  defexception [:message, :plug_status]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    status = Keyword.get(opts, :plug_status, 401)

    %__MODULE__{
      message: message,
      plug_status: status
    }
  end
end

defimpl Plug.Exception, for: Ecto.InvalidChangesetError do
  def status(_exception), do: 422
end