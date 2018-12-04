defmodule CsGuideWeb.AdminController do
  use CsGuideWeb, :controller

  import CsGuideWeb.Plugs.Auth

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
