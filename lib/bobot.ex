defmodule Bobot do
  defmodule CLI do
    def run(args) do
      IO.puts args
      connect
    end

    def connect do
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


      ##########################################################################

      muc_host  = "muc.im.a13.fr"
      muc_jid   = :exmpp_jid.make "arena", muc_host, "bobot"

      packet = :exmpp_xml.append_child(
        :exmpp_stanza.set_sender(
          :exmpp_stanza.set_recipient(
            :exmpp_presence.available(),
            muc_jid
          ),
          jid
        ),
        :exmpp_xml.element('http://jabber.org/protocol/muc', 'x')
      )

      :exmpp_session.send_packet session, packet

      :timer.sleep 8000
    end
  end
end
