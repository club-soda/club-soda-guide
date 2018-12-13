defmodule CsGuideWeb.SearchDrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, _params) do
    drinks = Drink.all()
    |> Drink.preload([:brand, :drink_types, :drink_styles, :drink_images])
    |> Enum.sort_by(fn d -> Map.get(d, :weighting, 0) end, &>=/2)

    drink_cards = Enum.map(drinks, fn d -> Drink.get_drink_card(d) end)

    render(conn, "index.html", drinks: drink_cards)
  end

end
