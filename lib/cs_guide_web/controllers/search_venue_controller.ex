defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue
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

    render(conn, "index.html", venues: cards)
  end

  def index(conn, _params) do
    cards =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v -> !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end) end)
      |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})
      |> Enum.map(&Venue.get_venue_card/1)

    render(conn, "index.html", venues: cards)
  end
end
