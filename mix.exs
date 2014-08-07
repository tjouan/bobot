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
    [
      applications: [:ssl, :exmpp],
      mod: {Bobot, []}
    ]
  end

  defp deps do
    [
      #{:exmpp, "~> 0.9.9", optional: true}
    ]
  end
end
