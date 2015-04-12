defmodule Bobot.Client do
  use GenServer

  alias Bobot.Client
  alias Bobot.Responder
  alias Bobot.XMPP
  alias Bobot.XMPP.JID
  alias Bobot.XMPP.Message
  alias Bobot.XMPP.Packet

  defstruct jid: nil, password: nil, room: nil, session: nil


  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end


  def init(config) do
    state = connect(%Client{
      jid:      JID.build(config.jid),
      password: config.password,
      room:     JID.parse(config.room)
    })

    XMPP.muc_join state.session, state.jid, state.room

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

  def handle_info(pkt, state) when is_tuple(pkt) and elem(pkt, 0) == :received_packet do
    state = handle_packet Packet.build(pkt), state
    {:noreply, state}
  end

  def handle_info({:muc_say, message}, state) do
    XMPP.muc_msg state.session, state.jid, state.room, message
    {:noreply, state}
  end

  def handle_info({:stream_error, :conflict}, state) do
    IO.puts "XMPP session conflict (same resource), stopping..."
    {:stop, :normal, state}
  end

  def handle_info({:DOWN, _monitor, :process, _pid, :tcp_closed}, state) do
    IO.puts "TCP session closed, reconnecting..."
    {:noreply, connect(state)}
  end

  def handle_info(msg, state) do
    IO.puts "Error, unhandled msg: #{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.puts "Terminate: #{inspect reason}"
    XMPP.stop_session state.session
    :ok
  end


  defp connect(state) do
    session = XMPP.start_session state.jid, state.password

    XMPP.presence_set_available session
    Process.monitor session

    %Client{state | session: session}
  end

  defp handle_packet(%Packet{type: :presence} = packet, state) do
    IO.puts "presence: <#{JID.to_s packet.from}> FIXME"
    state
  end

  defp handle_packet(%Packet{type: :message} = packet, state) do
    handle_message Message.build(packet), state
    state
  end

  defp handle_packet(packet, state) do
    IO.puts "PACKET: #{inspect packet}"
    state
  end

  defp handle_message(%Message{type: :chat} = message, state) do
    display_message message.from, message.body
    state
  end

  defp handle_message(%Message{type: :groupchat} = message, state) do
    display_message message.from, message.body
    if message.body != :undefined, do: Responder.handle(self(), message)
    state
  end

  defp handle_message(message, state) do
    IO.puts "XMPP UNKNOWN MESSAGE: #{inspect message}"
    state
  end

  defp display_message(from, body) do
    IO.puts "<#{JID.to_s from}> #{body}"
  end
end
