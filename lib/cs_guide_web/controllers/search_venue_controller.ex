defmodule CsGuideWeb.SearchVenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    venues = Venue.all()

    render(conn, "index.html", venues: venues)
  end
end
