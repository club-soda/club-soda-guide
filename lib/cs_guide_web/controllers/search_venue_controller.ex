defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    venues = Venue.all()
    |> Venue.preload([:venue_types, :venue_images])
    |> Enum.sort_by(& &1.venue_name)

    cards = Enum.map(venues, fn(v) -> get_venue_card(v) end)
    render(conn, "index.html", venues: cards)
  end

  defp get_venue_card(venue) do
    %{
      id: venue.entry_id,
      name: venue.venue_name,
      types: Enum.map(venue.venue_types, fn(v) -> v.name end),
      postcode: venue.postcode,
      cs_score: venue.cs_score,
      image:
        if img = List.first(venue.venue_images) do
          "https://s3-eu-west-1.amazonaws.com/#{Application.get_env(:ex_aws, :bucket)}/#{img.entry_id}"
        else
           if venue.external_image do
              venue.external_image
            else
              ""
            end
      end
    }
  end
end
