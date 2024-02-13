#!/usr/bin/env elixir

defmodule Search do
  defp recv(sock) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, resp} ->
        resp <> recv(sock)
      {:error, :closed} ->
        <<>>
    end
  end

  def search(query) do
    opts = [:binary, active: false, reuseaddr: true]
    {:ok, sock} = :gen_tcp.connect({:local, "/tmp/cocomel.sock"}, 0, opts)
    :ok = :gen_tcp.send(sock, <<0, 1, 5::native-16, 0::native-16, String.length(query)::native-16, query::binary>>)

    recv(sock)
  end

  def parse(<<>>), do: []

  def parse(<<url_len::native-16, url::binary-size(url_len), title_len::native-16, title::binary-size(title_len), snippet_len::native-16, snippet::binary-size(snippet_len), tail::binary>>) do
    [[url, title, snippet] | parse(tail)]
  end

  def print([]), do: nil

  def print([[url, title, snippet] | tail]) do
    IO.puts("#{title}\n#{url}\n#{snippet}\n")

    print(tail)
  end
end

query = IO.gets("Query> ")

<<_version::16, total_results::native-16, payload_results::native-16, payload::binary>> = Search.search(query)

IO.puts("Showing #{payload_results}/#{total_results}")

results = Search.parse(payload)
Search.print(results)
