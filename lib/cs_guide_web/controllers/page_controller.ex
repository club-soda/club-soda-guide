defmodule CsGuideWeb.PageController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> sort_by_cs_score()

    render(conn, "index.html", venues: venues)
  end

  def sort_by_cs_score(venues) do
    venues
    |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
    |> Enum.chunk_by(fn v ->
      v.cs_score
    end)
    |> Enum.map(fn list -> Enum.shuffle(list) end)
    |> List.flatten()
    |> Enum.slice(0, 4)
  end
end
