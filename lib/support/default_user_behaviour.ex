defmodule PhoenixGuardianAuth.DefaultUserBehaviour do
  @behaviour PhoenixGuardianAuth.UserControllerBehaviour
  import PhoenixGuardianAuth.Controller

  defp login_and_render(conn, user) do
    token = Guardian.Plug.current_token(Guardian.Plug.api_sign_in(conn, user))
    render_one conn, PhoenixGuardianAuth.TokenView, model: %{token: token, user: user}
  end

  def created(conn, _user) do
    render_message(conn, "user created, please confirm your account.")
  end

  def confirmed(conn, user) do
    login_and_render(conn, user)
  end

  def signed_in(conn, user) do
    login_and_render(conn, user)
  end

  def signed_out(conn, _user) do
    render_message(conn, "logout successfull")
  end

  def requested_reset(conn, _user) do
    render_message(conn, "please check your account")
  end

  def confirmed_reset(conn, user) do
    login_and_render(conn, user)
  end

  def updated(conn, _user) do
    render_message(conn, "user has been updated")
  end
end