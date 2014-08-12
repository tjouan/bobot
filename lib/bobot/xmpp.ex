defmodule Bobot.XMPP do
  alias Bobot.XMPP.JID


  def start_session(jid, password) do
    session = :exmpp_session.start
    :exmpp_session.auth_basic_digest session, jid, to_char_list password
    :exmpp_session.connect_SSL session, :exmpp_jid.domain_as_list(jid), 5223
    :exmpp_session.login session

    session
  end

  def stop_session(session) do
    :exmpp_session.stop session
  end

  def presence_set_available(session) do
    status = :exmpp_presence.set_status :exmpp_presence.available, ""
    :exmpp_session.send_packet session, status
  end

  def msg_is_delayed(msg) do
    case :exmpp_xml.get_element(msg, 'urn:xmpp:delay', 'delay') do
      :undefined  -> false
      _           -> true
    end
  end

  def muc_join(session, jid, room) do
    :exmpp_session.send_packet session, muc_packet_join(jid, room)
  end

  def muc_msg(session, jid, room, body) do
    packet = muc_packet_msg jid, JID.bare(room), body
    :exmpp_session.send_packet session, packet
  end

  def muc_packet_join(jid, room) do
    muc_element = :exmpp_xml.element('http://jabber.org/protocol/muc', 'x')

    :exmpp_presence.available
    |> :exmpp_stanza.set_recipient(room)
    |> :exmpp_stanza.set_sender(jid)
    |> :exmpp_xml.append_child(muc_element)
  end

  def muc_packet_msg(jid, room, body) do
    :exmpp_message.groupchat(to_char_list body)
    |> :exmpp_stanza.set_recipient(room)
    |> :exmpp_stanza.set_sender(jid)
  end
end
