defmodule Bobot.XMPP.Message do
  alias Bobot.XMPP
  alias Bobot.XMPP.Message
  alias Bobot.XMPP.Packet

  defstruct type: nil, from: nil, to: nil, body: nil, delayed: nil


  def build(packet) do
    %Message{
      type:     packet.attr,
      from:     packet.from,
      body:     Packet.message_body(packet),
      delayed:  XMPP.msg_is_delayed(packet.raw)
    }
  end
end
