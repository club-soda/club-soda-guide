defmodule CsGuideWeb.PageController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue
  alias CsGuideWeb.{VenueController, SearchVenueController}
  alias CsGuide.Sponsor

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        v.favourite
      end)
      |> Enum.slice(0, 4)
      |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
      |> Enum.map(fn v ->
        VenueController.sort_images_by_most_recent(v)
      end)
      |> Enum.map(&SearchVenueController.selectPhotoNumber1/1)

    sponsor = Sponsor.getShowingSponsor() || nil

    render(conn, "index.html", venues: venues, sponsor: sponsor)
  end
end
