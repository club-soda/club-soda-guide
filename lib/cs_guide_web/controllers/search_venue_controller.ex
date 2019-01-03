defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue
  alias CsGuide.PostcodeLatLong

  def index(conn, %{"ll" => latlong}) do
    [lat_str, long_str] = String.split(latlong, ",")
    {lat, _} = Float.parse(lat_str)
    {long, _} = Float.parse(long_str)

    venues = PostcodeLatLong.nearest_venues(lat, long)
    cards = create_venue_cards(venues)

    render(conn, "index.html", venues: cards)
  end

  def index(conn, _params) do
    venues = Venue.all()
    cards = create_venue_cards(venues)

    render(conn, "index.html", venues: cards)
  end

  defp create_venue_cards(venues) do
    venues
    |> Venue.preload([:venue_types, :venue_images])
    |> Enum.filter(fn v -> v.venue_types end)
    |> filter_retailers()
    |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})
    |> Enum.map(&Venue.get_venue_card/1)
  end

  defp filter_retailers(venues) do
    Enum.filter(venues, fn v ->
      if Enum.find(v.venue_types,
        fn type -> String.downcase(type.name) !== "retailers" end) do
        v
      end
    end)
  end
end
