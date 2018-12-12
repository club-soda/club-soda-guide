defmodule CsGuideWeb.SearchAllController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Drink, Venue}

  def index(conn, params) do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        v.venue_types
      end)
      |> Enum.filter(fn v ->
        if Enum.find(v.venue_types, fn type -> String.downcase(type.name) !== "retailers" end) do
          v
        end
      end)
      |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})

    venue_cards = Enum.map(venues, fn v -> Venue.get_venue_card(v) end)

    drinks = Drink.all()
    |> Drink.preload([:brand, :drink_types, :drink_styles, :drink_images])
    |> Enum.sort_by(fn d -> Map.get(d, :weighting, 0) end, &>=/2)

    drink_cards = Enum.map(drinks, fn d -> Drink.get_drink_card(d) end)

    render(conn, "index.html", venues: venue_cards, drinks: drink_cards, term: params["term"])
  end

end
