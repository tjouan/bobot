defmodule Bobot.Mixfile do
  use Mix.Project

  def project do
    [
      app:      :bobot,
      version:  "0.0.1",
      elixir:   "~> 1.0.2",
      deps:     deps
    ]
  end

  def application do
    [
      applications: [:exmpp],
      mod: {Bobot, []}
    ]
  end

  defp deps do
    [
      #{:exmpp, "~> 0.9.9", optional: true}
    ]
  end
end
