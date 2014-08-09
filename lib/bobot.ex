defmodule Bobot do
  use Application

  def start(_type, _args) do
    Bobot.Supervisor.start_link(Application.get_env(:bobot, :session))
  end
end
