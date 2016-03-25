defmodule PhoenixGuardianAuth.UserControllerBehaviour do
  use Behaviour
  
  defcallback created(Map.t, any)
  defcallback confirmed(Map.t, any)
  defcallback signed_in(Map.t, any)
  defcallback signed_out(Map.t, any)
  defcallback requested_reset(Map.t, any)
  defcallback confirmed_reset(Map.t, any)
  defcallback updated(Map.t, any)
end