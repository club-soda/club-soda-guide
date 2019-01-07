defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue
  alias CsGuide.Categories.VenueType

  def index(conn, params) do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end)
      end)
      |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})
    cards = Enum.map(venues, fn v -> Venue.get_venue_card(v) end)
    term = params["term"] || ""
    venue_types = VenueType.all() |> Enum.map(&(&1.name)) |> Enum.sort()

    render(conn, "index.html", venues: cards, term: term, venue_types: venue_types)
  end
end
