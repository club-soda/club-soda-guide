defmodule CsGuideWeb.SearchDrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, params) do
    drinks = Drink.all()
    |> Drink.preload([:brand, :drink_types, :drink_styles, :drink_images])
    |> Enum.sort_by(fn d -> Map.get(d, :weighting, 0) end, &>=/2)

    drink_cards = Enum.map(drinks, fn d -> Drink.get_drink_card(d) end)
    term = params["term"] || ""
    drink_type = (params["drink_type"] && Regex.replace(~r/_/,params["drink_type"], " ")) || "none";

    render(conn, "index.html", drinks: drink_cards, term: term, drink_type: drink_type)
  end

end
