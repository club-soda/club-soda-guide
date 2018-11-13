defmodule CsGuideWeb.PageController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Enum.shuffle()
      |> Enum.slice(0, 4)

    render(conn, "index.html", venues: venues)
  end
end
