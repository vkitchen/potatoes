#!/usr/bin/env elixir

opts = [:binary, active: false, reuseaddr: true]
{:ok, sock} = :gen_tcp.connect({:local, "/tmp/cocomel.sock"}, 0, opts)
:ok = :gen_tcp.send(sock, <<0, 1, 5, 0, 0, 0, 3, 0, 99, 97, 116>>)
{:ok, resp} = :gen_tcp.recv(sock, 0)

IO.puts(resp)
