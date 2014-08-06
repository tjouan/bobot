defmodule Bobot.Mixfile do
  use Mix.Project

  def project do
    [
      app:      :bobot,
      version:  "0.0.1",
      elixir:   "~> 0.14.3",
      deps:     deps
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    []
  end
end
