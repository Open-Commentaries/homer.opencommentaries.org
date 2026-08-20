defmodule AHCIPWeb.PageController do
  use AHCIPWeb, :controller

  alias AHCIP.WorkRegistry

  def home(conn, _params) do
    render(conn, :home, works: WorkRegistry.works())
  end

  def foreword(conn, _params) do
    foreword_html =
      "priv/static/markdown/foreword.md"
      |> File.read!()
      |> MDEx.to_html!()

    render(conn, :foreword, foreword_html: foreword_html)
  end
end
