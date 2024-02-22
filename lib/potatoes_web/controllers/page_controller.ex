defmodule PotatoesWeb.PageController do
  use PotatoesWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def search(conn, %{"q" => query}) do
    case String.length(query) do
      0 -> redirect(conn, to: ~p"/")
      _ ->
        results = Cocomel.search(query)
        render(conn, :search, query: query, results: results)
    end
  end

  def search(conn, _params) do
    redirect(conn, to: ~p"/")
  end
end
