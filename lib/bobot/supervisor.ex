defmodule Bobot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts "SUPERVISOR INIT"
    children = [
      worker(Bobot.Client, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
