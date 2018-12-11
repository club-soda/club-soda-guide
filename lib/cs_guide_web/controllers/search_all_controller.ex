defmodule CsGuideWeb.SearchAllController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, _params) do

    render(conn, "index.html", venues: [], drinks: [])
  end

end
