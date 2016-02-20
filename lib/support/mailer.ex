defmodule PhoenixTokenAuth.Mailer do
  require Logger

  @moduledoc """
  Responsible for sending mails.
  Configuration options:

      config @config_atom,
        email_sender: "myapp@example.com",
        mailgun_domain: "example.com",
        mailgun_key: "secret"
        emailing_module: PhoenixTokenAuth.TestMailing
  """

  @config_atom :phoenix_guardian_auth

  use Mailgun.Client, domain: Application.get_env(@config_atom, :mailgun_domain),
                      key: Application.get_env(@config_atom, :mailgun_key),
                      mode: Application.get_env(@config_atom, :mailgun_mode),
                      test_file_path: Application.get_env(@config_atom, :mailgun_test_file_path)


  @doc """
  Sends a welcome mail to the user.

  Subject and body can be configured in @config_atom, :welcome_email_subject and :welcome_email_body.
  Both config fields have to be functions returning binaries. welcome_email_subject receives the user and
  welcome_email_body the user and confirmation token.
  """
  def send_welcome_email(user, confirmation_token, conn \\ nil) do
    subject = email_mod.welcome_subject(user, conn)
    body = email_mod.welcome_body(user, confirmation_token, conn)
    from = Application.get_env(@config_atom, :email_sender)

    {:ok, _} = send_email(to: user.account,
               from: from,
               subject: subject,
               text: body)

    Logger.info "Sent welcome email to #{user.account}"
  end

  @doc """
  Sends an email with instructions on how to reset the password to the user.

  Subject and body can be configured in @config_atom, :password_reset_email_subject and :password_reset_email_body.
  Both config fields have to be functions returning binaries. password_reset_email_subject receives the user and
  password_reset_email_body the user and reset token.
  """
  def send_password_reset_email(user, reset_token, conn \\ nil) do
    subject = email_mod.password_reset_subject(user, conn)
    body = email_mod.password_reset_body(user, reset_token, conn)
    from = Application.get_env(@config_atom, :email_sender)

    {:ok, _} = send_email(to: user.account,
               from: from,
               subject: subject,
               text: body)

    Logger.info "Sent password_reset email to #{user.account}"
  end

  @doc """
  Sends an email with instructions on how to confirm a new email address to the user.

  Subject and body can be configured in @config_atom, :new_email_address_email_subject and :new_email_address_email_body.
  Both config fields have to be functions returning binaries. new_email_address_email_subject receives the user and
  new_email_address_email_body the user and confirmation token.
  """
  def send_new_email_address_email(user, confirmation_token, conn \\ nil) do
    subject = email_mod.new_email_address_subject(user, conn)
    body = email_mod.new_email_address_body(user, confirmation_token, conn)
    from = Application.get_env(@config_atom, :email_sender)

    {:ok, _} = send_email(to: user.unconfirmed_account,
               from: from,
               subject: subject,
               text: body)

    Logger.info "Sent new email address email to #{user.unconfirmed_account}"
  end

  defp email_mod do
    Application.get_env(@config_atom, :emailing_module)
  end

end
