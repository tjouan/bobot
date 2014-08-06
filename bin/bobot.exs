#!/usr/bin/env elixir

Code.prepend_path Path.expand("../_build/dev/lib/bobot/ebin", __DIR__)

if Code.ensure_loaded?(Bobot.CLI) do
  Bobot.CLI.run(System.argv)
else
  IO.puts :stderr, "Error: cannot load Bobot module, try to run: `mix compile'"
  exit 70
end
