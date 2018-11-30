defmodule CsGuideWeb.SearchVenueControllerTest do
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

    test "GET /search/venues", %{conn: conn, venue: venue} do
      conn = get(conn, "/search/venues")

      assert html_response(conn, 200) =~ "The Favourite Pub"
    end

    test "GET /search/venues contain not favourite venue", %{conn: conn, venue: venue} do
      conn = get(conn, "/search/venues")

      assert html_response(conn, 200) =~ "The Not Favourite Pub"
    end

  end

  def fixture(:venue) do
    %{name: "Pubs"}
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
