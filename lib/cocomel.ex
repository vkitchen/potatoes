defmodule Cocomel do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:search, query}, _from, state) do
    {:reply, query, state}
  end

  def search(query) do
    GenServer.call(__MODULE__, {:search, query})
  end
end


