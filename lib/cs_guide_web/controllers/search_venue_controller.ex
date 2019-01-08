defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue
  alias CsGuide.Categories.VenueType
  alias CsGuide.PostcodeLatLong

  def index(conn, %{"ll" => latlong}) do
    [lat_str, long_str] = String.split(latlong, ",")
    {lat, _} = Float.parse(lat_str)
    {long, _} = Float.parse(long_str)

    cards =
      PostcodeLatLong.nearest_venues(lat, long)
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v -> !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end) end)
      |> Enum.map(&Venue.get_venue_card/1)
      venue_types = getVenueTypes()

    render(conn, "index.html", venues: cards, term: "", venue_types: venue_types)
  end

  def index(conn, params) do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v -> !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end) end)
      |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})
    cards = Enum.map(venues, &Venue.get_venue_card/1)
    term = params["term"] || ""
    venue_types = getVenueTypes()

    render(conn, "index.html", venues: cards, term: term, venue_types: venue_types)
  end

  defp getVenueTypes do
    VenueType.all() |> Enum.map(&(&1.name)) |> Enum.sort()
  end
end
