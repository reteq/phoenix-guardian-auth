defmodule PhoenixGuardianAuth.Controller do

  def render_many(conn, model) do
    Phoenix.Controller.render(conn, "index.json", data: model)
  end
  def render_many(conn, view, model: model) do
    Phoenix.Controller.render(conn, view, "index.json", data: model)
  end

  def render_one(conn, model) do
    Phoenix.Controller.render(conn, "show.json", data: model)
  end

  def render_one(conn, view, model: model) do
    Phoenix.Controller.render(conn, view, "show.json", data: model)
  end

  def render_message(conn, message) do
    Phoenix.Controller.render(conn, PhoenixGuardianAuth.MessageView, "show.json", data: %{message: message})
  end

  def current_user(conn), do: Guardian.Plug.current_resource(conn)
end