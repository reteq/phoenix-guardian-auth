defmodule PhoenixGuardianAuth.Activatable do
  use Behaviour

  @doc """
  interface for sms provider which can be set in config.exs
  """
  defcallback send_welcome(Any, String.t, Plug.Conn.t)
  defcallback send_password_reset(Any, String.t, Plug.Conn.t)
  defcallback send_new_account(Any, String.t, Plug.Conn.t)
end