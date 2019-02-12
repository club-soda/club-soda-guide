defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue
  alias CsGuide.Categories.VenueType
  alias CsGuideWeb.VenueController

  def index(conn, params) do
    latlong = params["ll"]
    locationSearch = params["ll"] != nil
    postcode = (params["ll"] && params["postcode"]) || ""
    term = params["term"] || ""
    venue_types = getVenueTypes()

    cards =
      if latlong do
        [lat_str, long_str] = String.split(latlong, ",")
        {lat, _} = Float.parse(lat_str)
        {long, _} = Float.parse(long_str)

        getVenueCardsByLatLong(lat, long)
      else
        getAllVenueCards()
      end

    render(
      conn,
      "index.html",
      venues: cards,
      term: term,
      venue_types: venue_types,
      postcode: postcode,
      locationSearch: locationSearch
    )
  end

  defp getVenueTypes do
    VenueType.all()
    |> Enum.map(& &1.name)
    |> Enum.filter(&(String.downcase(&1) != "retailer" && String.downcase(&1) != "wholesaler"))
    |> Enum.sort()
  end

  defp getAllVenueCards do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type ->
          String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
        end)
      end)
      |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})
      |> Enum.map(&VenueController.sortImagesByMostRecent/1)
      |> Enum.map(&selectPhotoNumber1/1)
      |> Enum.map(&Venue.get_venue_card/1)
  end

  def selectPhotoNumber1(venue) do
    Map.update(venue, :venue_images, [], fn images ->
      images
      |> Enum.filter(fn i ->
        i.photo_number == 1
      end)
    end)
  end

  defp getVenueCardsByLatLong(lat, long) do
    Venue.nearest_venues(lat, long)
    |> Venue.preload([:venue_types, :venue_images])
    |> Enum.filter(fn v ->
      !Enum.find(v.venue_types, fn type ->
        String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
      end)
    end)
    |> Enum.map(&Venue.get_venue_card/1)
  end
end
