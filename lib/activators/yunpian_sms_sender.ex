defmodule PhoenixGuardianAuth.YunpianSMSender do
  @behaviour PhoenixGuardianAuth.Activatable

  @welcome_tpl_id Application.get_env(:phoenix_guardian_auth, :welcome_tpl_id)
  @password_reset_tpl_id Application.get_env(:phoenix_guardian_auth, :password_reset_tpl_id)
  @new_account_tpl_id Application.get_env(:phoenix_guardian_auth, :new_account_tpl_id)
  
  def send_welcome(user, confirmation_token, conn \\ nil) do
    Sms.send(user.account, confirmation_token, [tpl_id: @welcome_tpl_id])
  end

  def send_password_reset(user, reset_token, conn \\ nil) do
    Sms.send(user.account, reset_token, [tpl_id: @password_reset_tpl_id])
  end

  def send_new_account(user, confirmation_token, conn \\ nil) do
    Sms.send(user.account, confirmation_token, [tpl_id: @new_account_tpl_id])
  end

  def generate_token, do: :crypto.rand_uniform(1000, 9999) |> Integer.to_string
end