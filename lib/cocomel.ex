defmodule Cocomel do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  defp recv(sock) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, resp} ->
        resp <> recv(sock)
      {:error, :closed} ->
        <<>>
    end
  end

  defp parse(<<>>), do: []

  defp parse(<<url_len::native-16, url::binary-size(url_len), title_len::native-16, title::binary-size(title_len), snippet_len::native-16, snippet::binary-size(snippet_len), tail::binary>>) do
    [[url, title, snippet] | parse(tail)]
  end

  def handle_call({:search, query, page}, _from, state) do
    offset = 10 * (page - 1)

    opts = [:binary, active: false, reuseaddr: true]
    {:ok, sock} = :gen_tcp.connect({:local, "/tmp/cocomel.sock"}, 0, opts)
    :ok = :gen_tcp.send(sock, <<0, 1, 10::native-16, offset::native-16, String.length(query)::native-16, query::binary>>)

    <<_version::16, total_results::native-16, _payload_results::native-16, payload::binary>> = recv(sock)
    results = parse(payload)

    {:reply, %{ total: total_results, results: results }, state}
  end

  def search(query, page) do
    GenServer.call(__MODULE__, {:search, query, page})
  end
end
