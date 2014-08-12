defmodule Bobot.XMPP.JID do
  import Record

  defrecordp :jid,
    Record.extract(:jid, from_lib: "exmpp/include/exmpp_jid.hrl")


  def build(jid) do
    jid |> parse |> randomize_resource
  end

  def to_s(jid) do
    :exmpp_jid.to_binary jid
  end

  def make(jid) do
    :exmpp_jid.make jid
  end

  def parse(jid) do
    :exmpp_jid.parse jid
  end

  def bare(jid) do
    :exmpp_jid.bare jid
  end

  def randomize_resource(jid) do
    resource = :crypto.rand_uniform(16777216, 4294967296)
    |> Integer.to_string(16)
    |> String.downcase

    :exmpp_jid.make(jid(jid, :node), jid(jid, :domain), resource)
  end
end
