defmodule Bobot do
  defmodule CLI do
    def run(args) do
      IO.puts args
      connect
    end

    def connect do
      session = :exmpp_session.start

      host    = "im.a13.fr"
      jid     = :exmpp_jid.make "bobot", host, "origin"
      pass    = "MYPASSWORD"

      :exmpp_session.auth_basic_digest session, jid, String.to_char_list pass
      #:exmpp_session.connect_TCP session, ehost, 5222, starttls: :enabled
      :exmpp_session.connect_SSL session, String.to_char_list(host), 5223
      :exmpp_session.login session
    end
  end
end
