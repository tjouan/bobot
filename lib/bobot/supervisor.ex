defmodule Bobot.Supervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(config) do
    children = [
      worker(Bobot.Client, [config], restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
