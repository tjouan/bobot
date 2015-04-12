defmodule Bobot.Responder do
  @responses  Application.get_env :bobot, :responses
  @delay_min  2
  @delay_max  8

  alias Bobot.XMPP.Message

  def handle(client, message) do
    case find_response(message) do
      {pattern, response_fmts} ->
        response = make_response pattern, response_fmts, message
        delay = :crypto.rand_uniform @delay_min, @delay_max + 1
        Process.send_after(client, {:muc_say, response}, delay * 1000)
      _ ->
    end
  end

  defp find_response(%Message{delayed: false} = message) do
    Enum.find @responses, fn({r, _}) -> message.body =~ r end
  end

  defp find_response(_) do
  end

  defp make_response(pattern, response_fmts, message) do
    captures  = Regex.run pattern, message.body, capture: :all_but_first
    format    = :lists.nth :random.uniform(length response_fmts), response_fmts

    Enum.reduce captures, format, fn(capture, acc) ->
      String.replace acc, "%s", capture
    end
  end
end
