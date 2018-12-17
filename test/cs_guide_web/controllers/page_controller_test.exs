defmodule CsGuideWeb.PageControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Resources, Categories}

  @venues [
    %{
      venue_name: "The Favourite Pub",
      favourite: true,
      venue_types: %{"Pubs" => "on"},
      postcode: "TW3 5FG"
    },
    %{
      venue_name: "The Not Favourite Pub",
      favourite: false,
      venue_types: %{"Pubs" => "on"},
      postcode: "SW1 4RV"
    }
  ]
  describe "renders landing page as expected" do
    setup [:create_venue]

    test "GET /", %{conn: conn, venue: _venue} do
      conn = get(conn, "/")

      assert html_response(conn, 200) =~
               "The best low and no alcohol drinks and where to find them"
    end

    test "Favourite venue shows", %{conn: conn, venue: _venue} do
      conn = get(conn, "/")

      assert html_response(conn, 200) =~ "The Favourite Pub"
    end

    test "Not favourite venue doesn't show", %{conn: conn, venue: _venue} do
      conn = get(conn, "/")

      assert html_response(conn, 200) != "The Not Favourite Pub"
    end
  end

  def fixture(:venue) do
    %Categories.VenueType{}
    |> Categories.VenueType.changeset(%{name: "Pubs"})
    |> Categories.VenueType.insert()

    @venues
    |> Enum.map(fn v ->
      {:ok, venue} = Resources.Venue.insert(v)
      venue
    end)
  end

  def create_venue(_) do
    venue = fixture(:venue)
    {:ok, venue: venue}
  end
end
