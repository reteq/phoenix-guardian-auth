defmodule PhoenixGuardianAuth.YunpianSMSender do
  @behaviour PhoenixGuardianAuth.Activatable

  @yunpian Application.get_env(:phoenix_guardian_auth, :yunpian_template)
  
  def send_welcome(user, confirmation_token, conn \\ nil) do
    {body, id} = @yunpian.welcome_body(user, confirmation_token, conn) 
    Sms.send(user.account, body, [tpl_id: id])
  end

  def send_password_reset(user, reset_token, conn \\ nil) do
    {body, id} = @yunpian.password_reset_body(user, reset_token, conn) 
    Sms.send(user.account, body, [tpl_id: id])
  end

  def send_new_account(user, confirmation_token, conn \\ nil) do
    {body, id} = @yunpian.new_phone_number_body(user, confirmation_token, conn) 
    Sms.send(user.unconfirmed_account, body, [tpl_id: id])
  end

  def generate_token, do: :crypto.rand_uniform(1000, 9999) |> Integer.to_string
end