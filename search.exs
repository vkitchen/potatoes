#!/usr/bin/env elixir

opts = [:binary, active: false, reuseaddr: true]
{:ok, sock} = :gen_tcp.connect({:local, "/tmp/cocomel.sock"}, 0, opts)
:ok = :gen_tcp.send(sock, <<0, 1, 5, 0, 0, 0, 3, 0, 99, 97, 116>>)
{:ok, resp1} = :gen_tcp.recv(sock, 0)
{:ok, resp2} = :gen_tcp.recv(sock, 0)
{:ok, resp3} = :gen_tcp.recv(sock, 0)
{:error, :closed} = :gen_tcp.recv(sock, 0)

resp = resp1 <> resp2 <> resp3

<<_version::size(16), total_results::native-integer-size(16), payload_results::native-integer-size(16), payload::binary>> = resp

defmodule Foo do
  def parse(<<>>), do: []

  def parse(<<url_len::native-integer-size(16), url::binary-size(url_len), title_len::native-integer-size(16), title::binary-size(title_len), snippet_len::native-integer-size(16), snippet::binary-size(snippet_len), tail::binary>>) do
    [[url, title, snippet] | parse(tail)]
  end

  def print([]), do: nil

  def print([[url, title, snippet] | tail]) do
    IO.puts(url)
    IO.puts(title)
    IO.puts(snippet)

    print(tail)
  end


end

IO.puts("Total number of results: #{total_results}")
IO.puts("Results received: #{payload_results}")

results = Foo.parse(payload)
Foo.print(results)
