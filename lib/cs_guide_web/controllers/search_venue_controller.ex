defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue

  def index(conn, params) do
    venues = Venue.all()

    render(conn, "index.html", venues: venues)
  end
end
