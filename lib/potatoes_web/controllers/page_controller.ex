defmodule PotatoesWeb.PageController do
  use PotatoesWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def search(conn, %{ "q" => query, "page" => page_raw }) do
    case String.length(query) do
      0 -> redirect(conn, to: ~p"/")
      _ ->
        { page, _ } = Integer.parse(page_raw)
        %{ total: total, results: results } = Cocomel.search(query, page)
        render(conn, :search, layout: false, query: query, page: page, total: total, results: results)
    end
  end

  def search(conn, _params) do
    redirect(conn, to: ~p"/")
  end
end
