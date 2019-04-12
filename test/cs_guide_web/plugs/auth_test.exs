defmodule CsGuideWeb.Plugs.AuthTest do
  use CsGuideWeb.ConnCase
  import CsGuide.SetupHelpers
  alias CsGuide.Fixtures
  alias CsGuide.Resources.Venue
  alias CsGuide.Categories.VenueType

  @create_venues Fixtures.create_venues()
  @create_venue_types Fixtures.create_venue_types()

  @create_attrs %{
    parent_company: "Parent Co",
    address: "number and road",
    city: "London",
    phone_number: "01234567890",
    postcode: "EC1M 5AD",
    venue_name: "The Example Pub",
    venue_types: %{"Bar" => "on"},
    users: %{"0" => %{"email" => "bob@dwyl.com"}}
  }

  def create_venues(_) do
    @create_venue_types
    |> Enum.map(fn vt ->
      {:ok, _venue_type} =
        %VenueType{}
        |> VenueType.changeset(vt)
        |> VenueType.insert()
    end)

    venues =
      @create_venues
      |> Enum.map(fn v ->
        {:ok, venue} = Venue.insert(v)
        venue
      end)

    {:ok, venues: venues}
  end

  describe "venue_owner plug on routes when the logged in venue admin is not a owner for the venue in question" do
    setup [:create_venues, :venue_admin_login]

    test "get /retailers/:id/add_drinks", %{conn: conn} do
      venue = Venue.get_by(slug: "venue-a-ec1a-7aa")
      conn = get(conn, retailer_path(conn, :add_drinks, venue.entry_id))
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) == "You need to be this venues admin to access this page"
    end

    test "get /venues/:slug/add_drinks", %{conn: conn} do
      conn = get(conn, venue_path(conn, :add_drinks, "venue-a-ec1a-7aa"))
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) == "You need to be this venues admin to access this page"
    end

    test "get /venues/:slug/add_photo", %{conn: conn} do
      conn = get(conn, venue_path(conn, :add_photo, "venue-a-ec1a-7aa"))
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) == "You need to be this venues admin to access this page"
    end

    test "get /wholesalers/:id/add_drinks", %{conn: conn} do
      venue = Venue.get_by(slug: "venue-a-ec1a-7aa")
      conn = get(conn, wholesaler_path(conn, :add_drinks, venue.entry_id))
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) == "You need to be this venues admin to access this page"
    end

    test "post /venues/:id/", %{conn: conn} do
      venue = Venue.get_by(slug: "venue-a-ec1a-7aa")
      conn = post(conn, venue_path(conn, :upload_photo, venue.entry_id), %{})
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) == "You need to be this venues admin to access this page"
    end
  end

  describe "venue_owner plug on routes when logged in admin is owner of venue in question" do
    setup %{conn: conn} do
      %VenueType{}
      |> VenueType.changeset(%{name: "Bar"})
      |> VenueType.insert()

      conn = post(conn, signup_path(conn, :create), venue: @create_attrs)
      {:ok, conn: conn}
    end

    test "get /venues/:slug/add_drinks", %{conn: conn} do
      conn = get(conn, venue_path(conn, :add_drinks, "the-example-pub-ec1m-5ad"))
      assert html_response(conn, 200) =~ "Add products to your stocklist"
    end
  end

  describe "No one logged in" do
    setup [:create_venues]

    test "gets redirected to login screen", %{conn: conn} do
      conn = get(conn, venue_path(conn, :add_drinks, "venue-a-ec1a-7aa"))
      assert redirected_to(conn) == session_path(conn, :new)
      assert get_flash(conn, :error) == "You must be logged in to view this page"
    end
  end
end
