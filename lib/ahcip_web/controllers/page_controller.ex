defmodule AHCIPWeb.PageController do
  use AHCIPWeb, :controller

  alias AHCIP.WorkRegistry

  def home(conn, _params) do
    render(conn, :home, works: WorkRegistry.works())
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end
