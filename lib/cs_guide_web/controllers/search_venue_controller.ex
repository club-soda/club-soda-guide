defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue

  def index(conn, _params) do
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

    cards = Enum.map(venues, fn v -> Venue.get_venue_card(v) end)
    render(conn, "index.html", venues: cards)
  end


end
