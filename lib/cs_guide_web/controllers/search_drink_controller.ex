defmodule CsGuideWeb.SearchDrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, params) do
    drinks = Drink.all()
    render(conn, "index.html", drinks: drinks)
  end
end
