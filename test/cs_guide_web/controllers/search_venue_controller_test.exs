defmodule CsGuideWeb.SearchVenueControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Resources, Categories}

  @venues [
    %{
      venue_name: "The Favourite Pub",
      parent_company: "Parent Co",
      favourite: true,
      venue_types: %{"Pubs" => "on"},
      postcode: "G1 1HF",
      lat: "55.858737212319600",
      long: "-4.243474091424120",
      slug: "the-favourite-pub-g1-1hf"
    },
    %{
      venue_name: "The Not Favourite Pub",
      parent_company: "Parent Co",
      favourite: false,
      venue_types: %{"Pubs" => "on"},
      postcode: "E2 0SY",
      lat: "51.529675468124100",
      long: "-0.042065456864592",
      slug: "the-not-favourite-pub-e2-0sy"
    },
    %{
      venue_name: "same location as not fav",
      parent_company: "Parent Co",
      favourite: false,
      venue_types: %{"Pubs" => "on"},
      postcode: "E2 0SY",
      lat: "51.529675468124100",
      long: "-0.042065456864592",
      slug: "same-location-as-not-fav-e2-0sy"
    },
    %{
      venue_name: "The Retailer",
      parent_company: "Parent Co",
      favourite: false,
      venue_types: %{"Retailer" => "on"},
      postcode: "SW1 4RV",
      lat: "51.468175746794700",
      long: "-0.363049000000000",
      slug: "retailer"
    }
  ]

  describe "renders landing page as expected" do
    setup [:create_venue]

    test "GET /search/venues", %{conn: conn} do
      conn = get(conn, "/search/venues")

      assert html_response(conn, 200) =~ "The Favourite Pub"
    end

    test "GET /search/venues contains expected venues", %{conn: conn} do
      conn = get(conn, "/search/venues")

      assert html_response(conn, 200) =~ "The Not Favourite Pub"
      assert html_response(conn, 200) =~ "same location as not fav"
    end

    test "GET /search/venues doesn't contain retailer", %{conn: conn} do
      conn = get(conn, "/search/venues")

      refute html_response(conn, 200) =~ "The Retailer"
    end
  end

  describe "renders search/venues with nearby venues" do
    setup [:create_venue]

    test "GET /search/venues?ll=(north london latlong) does not display venues that are too far",
         %{conn: conn} do
      conn = get(conn, "/search/venues?ll=51.54359770000001,-0.08807799999999999")

      refute html_response(conn, 200) =~ "The Favourite Pub"
    end

    test "GET /search/venues?ll=(north london latlong) displays nearby venues", %{conn: conn} do
      conn = get(conn, "/search/venues?ll=51.54359770000001,-0.08807799999999999")

      assert html_response(conn, 200) =~ "The Not Favourite Pub"
    end
  end

  describe "renders nearby venues - latest venue version" do
    setup [:create_venue, :update_venue]

    test "GET /search/venues?ll=(north london latlong) displays nearby venues with the latest venue version",
         %{conn: conn} do
      conn = get(conn, "/search/venues?ll=51.54359770000001,-0.08807799999999999")

      refute html_response(conn, 200) =~ "The Not Favourite Pub"
      assert html_response(conn, 200) =~ "new version venue"
    end
  end

  def fixture(:venue) do
    %Categories.VenueType{}
    |> Categories.VenueType.changeset(%{name: "Pubs"})
    |> Categories.VenueType.insert()

    %Categories.VenueType{}
    |> Categories.VenueType.changeset(%{name: "Retailer"})
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

  def update_venue(_) do
    not_fav_pub =
      Resources.Venue.get_by(slug: "the-not-favourite-pub-e2-0sy")
      |> Resources.Venue.preload(
        drinks: [:brand, :drink_types, :drink_styles, :drink_images],
        venue_types: [],
        venue_images: [],
        users: []
      )

    attrs = not_fav_pub |> Map.from_struct() |> Map.merge(%{venue_name: "new version venue"})
    attrs = if attrs.users, do: Map.delete(attrs, :users)

    {:ok, _v} = Resources.Venue.update(not_fav_pub, attrs)
    :ok
  end
end
