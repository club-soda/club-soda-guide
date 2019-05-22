defmodule CsGuideWeb.PageControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Resources, Categories}

  @venues [
    %{
      venue_name: "The Favourite Pub",
      parent_company: "Parent Co",
      favourite: true,
      venue_types: %{"Pubs" => "on"},
      postcode: "TW3 4DF",
      slug: "the-favourite-pub-tw3-4df"
    },
    %{
      venue_name: "The Not Favourite Pub",
      parent_company: "Parent Co",
      favourite: false,
      venue_types: %{"Pubs" => "on"},
      postcode: "SW1P 4DF",
      slug: "the-not-favourite-pub-sw1-4df"
    }
  ]
  describe "renders landing page as expected" do
    setup [:create_venue]

    test "GET /", %{conn: conn, venue: _venue} do
      conn = get(conn, "/")

      assert html_response(conn, 200) =~ "The best low and no alcohol drinks and where to find them"
      assert html_response(conn, 200) =~ "The Club Soda Guide is the UK’s first directory for low and no alcohol drinks, and the best places to find them."
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

  describe "Displays 404 page for nonexistent endpoint" do
    test "404 page displays", %{conn: conn} do
      conn = get(conn, "/nonexistent_endpoint")

      assert html_response(conn, 200) =~ "Oops! That page could not be found."
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
