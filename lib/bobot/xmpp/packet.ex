defmodule Bobot.XMPP.Packet do
  alias Bobot.XMPP.JID
  alias Bobot.XMPP.Packet

  defstruct type: nil, attr: nil, from: nil, raw: nil

  import Record

  defrecordp :received_packet,
    Record.extract(:received_packet, from_lib: "exmpp/include/exmpp_client.hrl")


  def build(received_packet(packet_type: type, type_attr: attr, from: from,
    raw_packet: packet)) do
      %Packet{
        type: type,
        attr: List.to_atom(attr),
        from: JID.make(from),
        raw:  packet
      }
  end

  def message_body(%Packet{type: :message, raw: raw}) do
    :exmpp_message.get_body raw
  end
end
