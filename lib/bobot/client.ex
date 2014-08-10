defmodule Bobot.Client do
  use GenServer

  alias Bobot.Client

  defstruct jid: nil, password: nil, room: nil, session: nil

  import Record
  defrecordp :received_packet,
    Record.extract(:received_packet, from_lib: "exmpp/include/exmpp_client.hrl")
  # packet_type, % message, iq, presence
  # type_attr,   % depend on packet. Example: set, get, subscribe, etc
  # from,        % JID
  # id,          % Packet ID
  # queryns,     % IQ only: Namespace of the query
  # raw_packet   % raw exmpp record


  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(config) do
    state = connect(%Client{
      jid:      :exmpp_jid.parse(config.jid),
      password: config.password,
      room:     config.room
    })
    {:ok, state}
  end

  def handle_call(msg, _from, state) do
    IO.puts "handle_call #{inspect msg}"
    return_value = nil
    {:reply, return_value, state}
  end

  def handle_cast(msg, state) do
    IO.puts "handle_cast #{inspect msg}"
    {:noreply, state}
  end

  def handle_info(received_packet(packet_type: :message, type_attr: 'chat',
    from: from, raw_packet: packet), state) do
      from_jid  = :exmpp_jid.make from
      body      = :exmpp_message.get_body packet
      IO.puts "<#{:exmpp_jid.to_binary from_jid}> #{body}"
      {:noreply, state}
  end

  def handle_info(received_packet(packet_type: :message, type_attr: 'groupchat',
    from: from, raw_packet: packet), state) do
      from_jid  = :exmpp_jid.make from
      body      = :exmpp_message.get_body packet
      if !msg_is_delayed(packet) do
        IO.puts "<#{:exmpp_jid.to_binary from_jid}> #{body}"
      end
      {:noreply, state}
  end

  def handle_info(received_packet(packet_type: :message, type_attr: type_attr,
    from: from, raw_packet: packet), state) do
      IO.puts "------------------------------------------------------"
      IO.puts "MESSAGE TYPE_ATTR: #{inspect type_attr}"
      IO.puts "FPACKET: #{:exmpp_xml.document_to_list packet}"
      IO.puts "------------------------------------------------------"
      {:noreply, state}
  end

  def handle_info(received_packet(packet_type: packet_type, type_attr: type_attr,
    from: from, raw_packet: packet), state) do
      IO.puts "------------------------------------------------------"
      IO.puts "PACKET TYPE: #{inspect packet_type}"
      IO.puts "FPACKET: #{:exmpp_xml.document_to_list packet}"
      IO.puts "------------------------------------------------------"
      {:noreply, state}
  end

  def handle_info({:stream_error, :conflict}, state) do
    IO.puts "XMPP session conflict (same resource), stopping..."
    {:stop, :normal, state}
  end

  def handle_info({:DOWN, _monitor, :process, pid, :tcp_closed}, state) do
    IO.puts "TCP session closed, reconnecting..."
    {:noreply, connect(state)}
  end

  def handle_info(msg, state) do
    IO.puts "------------------------------------------------------"
    IO.puts "MSG #{inspect msg}"
    IO.puts "------------------------------------------------------"
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.puts "Terminate: #{inspect reason}"
    :exmpp_session.stop state.session
    :ok
  end

  def connect(state) do
    state = %Client{state | session: :exmpp_session.start}

    :exmpp_session.auth_basic_digest state.session, state.jid, to_char_list state.password
    #:exmpp_session.connect_TCP session, ehost, 5222, starttls: :enabled
    :exmpp_session.connect_SSL state.session, :exmpp_jid.domain_as_list(state.jid), 5223
    :exmpp_session.login state.session

    status = :exmpp_presence.set_status :exmpp_presence.available(), ""
    :exmpp_session.send_packet state.session, status

    muc_jid   = :exmpp_jid.parse state.room
    room_jid  = :exmpp_jid.bare muc_jid
    :exmpp_session.send_packet state.session, muc_join_packet(state.jid, muc_jid)
    :exmpp_session.send_packet state.session, muc_msg(state.jid, room_jid, "bobot!")

    Process.monitor state.session

    state
  end

  def muc_join_packet(jid, muc_jid) do
    muc_element = :exmpp_xml.element('http://jabber.org/protocol/muc', 'x')
    :exmpp_presence.available
    |> :exmpp_stanza.set_recipient(muc_jid)
    |> :exmpp_stanza.set_sender(jid)
    |> :exmpp_xml.append_child(muc_element)
  end

  def muc_msg(jid, room_jid, body) do
    :exmpp_message.groupchat(to_char_list body)
    |> :exmpp_stanza.set_recipient(room_jid)
    |> :exmpp_stanza.set_sender(jid)
  end

  def msg_is_delayed(msg) do
    case :exmpp_xml.get_element(msg, 'urn:xmpp:delay', 'delay') do
      :undefined  -> false
      _           -> true
    end
  end
end
