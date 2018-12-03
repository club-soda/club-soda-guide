defmodule CsGuideWeb.AdminController do
  use CsGuideWeb, :controller

  import CsGuideWeb.Plugs.Auth

  plug(:authenticate_user, admin: true)

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
