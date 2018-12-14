defmodule CsGuideWeb.PageController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue
  alias CsGuide.StaticPage

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        v.favourite
      end)
      |> Enum.slice(0, 4)
      |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)

    static_pages =
      StaticPage.all()
      |> Enum.filter(fn p ->
        p.display_in_menu || p.display_in_footer
      end)

    render(conn, "index.html", venues: venues, static_pages: static_pages)
  end
end
