defmodule CsGuideWeb.AdminController do
  use CsGuideWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
