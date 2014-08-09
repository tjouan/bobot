defmodule Bobot.Client do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(args) do
    IO.puts "CLIENT INIT #{inspect args}"
    connect
    state = []
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

  def handle_info(msg, state) do
    #IO.puts "handle_info #{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.puts "terminate #{inspect reason}"
    #:exmpp_session.stop session
    :ok
  end

  def connect do
    IO.puts "CLIENT CONNECT"

    session = :exmpp_session.start

    host    = "im.a13.fr"
    jid     = :exmpp_jid.make "bobot", host, "electrons"
    pass    = "oRdc3MzUxwzeoMEC"

    :exmpp_session.auth_basic_digest session, jid, String.to_char_list pass
    #:exmpp_session.connect_TCP session, ehost, 5222, starttls: :enabled
    :exmpp_session.connect_SSL session, String.to_char_list(host), 5223
    :exmpp_session.login session

    status = :exmpp_presence.set_status :exmpp_presence.available(), ""
    :exmpp_session.send_packet session, status

    muc_host  = "muc.im.a13.fr"
    muc_jid   = :exmpp_jid.make "arena", muc_host, "bobot"
    room_jid  = :exmpp_jid.make "arena", muc_host

    :exmpp_session.send_packet session, muc_join_packet(jid, muc_jid)
    :exmpp_session.send_packet session, muc_msg(jid, room_jid, "bobot!")
  end

  def muc_join_packet(jid, muc_jid) do
    :exmpp_xml.append_child(
      :exmpp_stanza.set_sender(
        :exmpp_stanza.set_recipient(
          :exmpp_presence.available(),
          muc_jid
        ),
        jid
      ),
      :exmpp_xml.element('http://jabber.org/protocol/muc', 'x')
    )
  end

  def muc_msg(jid, room_jid, body) do
    :exmpp_stanza.set_sender(
      :exmpp_stanza.set_recipient(
        :exmpp_message.groupchat(String.to_char_list(body)),
        room_jid
      ),
      jid
    )
  end
end
