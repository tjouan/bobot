defmodule Bobot do
  defmodule CLI do
    def run(args) do
      IO.puts args
      connect
    end

    def connect do
      :application.start :exmpp

      host    = "im.a13.fr"
      session = :exmpp_session.start
      jid     = :exmpp_jid.make "bobot", host, "origin"

      ehost = :erlang.binary_to_list host
      epass = :erlang.binary_to_list "MYPASSWORD"

      :exmpp_session.auth_basic_digest session, jid, epass
      #:exmpp_session.connect_TCP session, ehost, 5222, starttls: :enabled
      :exmpp_session.connect_SSL session, ehost, 5223
      :exmpp_session.login session
    end
  end
end
