defmodule CsGuideWeb.PageController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        v.favourite
      end)
      |> Enum.slice(0, 4)

    render(conn, "index.html", venues: venues)
  end
end
