defmodule PhoenixGuardianAuth.Error do
  defstruct [:message, :errors]
  @type t :: %__MODULE__{message: String.t, errors: [PhoenixGuardianAuth.ErrorItem.t]}
  @type convertible :: PhoenixGuardianAuth.ErrorConvertible.t

  @spec to_error(convertible) :: PhoenixGuardianAuth.Error.t
  def to_error(e), do: PhoenixGuardianAuth.ErrorConvertible.to_error(e)
end

defprotocol PhoenixGuardianAuth.ErrorConvertible do
  @fallback_to_any !Application.get_env(:necta, :raise_system_error, true)

  @spec to_error(t) :: PhoenixGuardianAuth.Error.t
  def to_error(error_convertible)
end

defimpl PhoenixGuardianAuth.ErrorConvertible, for: Ecto.Changeset do
  def to_error(%Ecto.Changeset{
    errors: errors,
    model: %{__meta__: %{source: {_, resource}}}
    }) do
    errors = errors |> Enum.map(fn {k, v} -> %{resource: resource, field: k, code: v} end)
    %PhoenixGuardianAuth.Error{message: "Validation failed", errors: errors}
  end
end

defimpl PhoenixGuardianAuth.ErrorConvertible, for: Ecto.NoResultsError do
  def to_error(%Ecto.NoResultsError{message: _message}) do
    %PhoenixGuardianAuth.Error{message: "NoResultsError", errors: []}
  end
end

defimpl PhoenixGuardianAuth.ErrorConvertible, for: PhoenixGuardianAuth.AuthException do
  def to_error(%PhoenixGuardianAuth.AuthException{message: message}) do
    %PhoenixGuardianAuth.Error{message: message, errors: []}
  end
end

defimpl PhoenixGuardianAuth.ErrorConvertible, for: PhoenixGuardianAuth.Error do
  def to_error(%PhoenixGuardianAuth.Error{} = error), do: error
end

defimpl PhoenixGuardianAuth.ErrorConvertible, for: Any do
  def to_error(%{message: message}) do
    %PhoenixGuardianAuth.Error{message: message, errors: []}
  end
  def to_error(_) do
    %PhoenixGuardianAuth.Error{message: "Invlid request", errors: []}
  end
end

defmodule PhoenixGuardianAuth.ErrorItem do
  defstruct [:resource, :field, :code]
  @type t :: %__MODULE__{resource: String.t, field: String.t, code: String.t}
end