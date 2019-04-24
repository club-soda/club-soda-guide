defmodule CsGuideWeb.PageController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue
  alias CsGuideWeb.{VenueController, SearchVenueController}
  alias CsGuide.Sponsor
  @prefix "https://s3-eu-west-1.amazonaws.com/club-soda-staging/"

  def index(conn, _params) do
    bucket_list =
      "AWS_S3_BUCKET"
      |> System.get_env()
      |> ExAws.S3.list_objects()
      |> ExAws.request!()

    contents = bucket_list.body.contents
    img_urls = Enum.map(contents, &("#{@prefix}#{&1.key}"))

    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        v.favourite
      end)
      |> Enum.slice(0, 4)
      |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
      |> Enum.map(fn v ->
        VenueController.sortImagesByMostRecent(v)
      end)
      |> Enum.map(&SearchVenueController.selectPhotoNumber1/1)

    sponsor = Sponsor.getShowingSponsor() || nil

    render(conn, "index.html", venues: venues, sponsor: sponsor, img_urls: img_urls)
  end
end
