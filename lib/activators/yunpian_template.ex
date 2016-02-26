defmodule PhoenixGuardianAuth.YunpianTemplate do
  use Behaviour
  
  defcallback welcome_body(any, String.t, Map.t) :: {String.t, String.t}
  defcallback password_reset_body(any, String.t, Map.t) :: {String.t, String.t}
  defcallback new_phone_number_body(any, String.t, Map.t) :: {String.t, String.t}
end