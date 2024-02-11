#!/usr/bin/env elixir

opts = [:binary, active: false, reuseaddr: true]
{:ok, sock} = :gen_tcp.connect({:local, "/tmp/cocomel.sock"}, 0, opts)
:ok = :gen_tcp.send(sock, <<0, 1, 5, 0, 0, 0, 3, 0, 99, 97, 116>>)
{:ok, resp} = :gen_tcp.recv(sock, 0)

<<_version::size(16), total_results::native-integer-size(16), payload_results::native-integer-size(16), rest::binary>> = resp

IO.puts("Total number of results: #{total_results}")
IO.puts("Results received: #{payload_results}")

IO.puts(rest)
