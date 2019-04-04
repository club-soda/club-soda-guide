defmodule CsGuideWeb.WholesalerControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.Fixtures
  alias CsGuide.{Resources, Categories}

  import CsGuide.SetupHelpers

  @create_brand Fixtures.create_brand()
  @create_types Fixtures.create_types()
  @create_drinks Fixtures.create_drinks()
  @create_venue_types Fixtures.create_venue_types()

  @create_attrs %{
    venue_name: "Amazon",
    website: "http://www.test.com",
    venue_types: %{"Wholesaler" => "on"}
  }

  @invalid_attrs %{venue_types: nil, website: nil, venue_name: nil}

  def fixture(:wholesaler) do
    @create_venue_types
    |> Enum.map(fn vt ->
      {:ok, _venue_type} =
        %Categories.VenueType{}
        |> Categories.VenueType.changeset(vt)
        |> Categories.VenueType.insert()
    end)

    {:ok, wholesaler} =
      @create_attrs
      |> Resources.Venue.retailer_insert()

    wholesaler
  end

  def fixture(:brand) do
    {:ok, brand} =
      @create_brand
      |> Resources.Brand.insert()

    brand
  end

  def fixture(:type) do
    types =
      @create_types
      |> Enum.map(fn t ->
        {:ok, type} = Categories.DrinkType.insert(t)
        type
      end)

    types
  end

  def fixture(:drink, brand) do
    drinks =
      @create_drinks
      |> Enum.map(fn d ->
        {:ok, drink} =
          Map.put(d, :brand, brand)
          |> Resources.Drink.insert()

        drink
      end)

    drinks
  end

  describe "index" do
    test "does not list wholesalers if not logged in", %{conn: conn} do
      conn = get(conn, wholesaler_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all wholesalers", %{conn: conn} do
      conn = get(conn, wholesaler_path(conn, :index))
      assert html_response(conn, 200) =~ "All Wholesalers"
    end
  end

  describe "new wholesaler" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, wholesaler_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new wholesaler - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, wholesaler_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wholesaler"
    end
  end

  describe "create wholesaler" do
    setup [:create_wholesaler, :admin_login]

    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, wholesaler_path(conn, :create), venue: @create_attrs)

      assert redirected_to(conn) == wholesaler_path(conn, :index)

      conn = get(conn, wholesaler_path(conn, :index))
      assert html_response(conn, 200) =~ "All Wholesalers"
      assert html_response(conn, 200) =~ "Amazon"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, wholesaler_path(conn, :create), venue: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wholesaler"
    end
  end

  describe "edit wholesaler" do
    setup [:create_wholesaler]

    test "does not render form when not logged in", %{conn: conn, wholesaler: wholesaler} do
      conn = get(conn, wholesaler_path(conn, :edit, wholesaler.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit wholesaler - admin" do
    setup [:create_wholesaler, :admin_login]

    test "renders form for editing chosen wholesaler", %{conn: conn, wholesaler: wholesaler} do
      conn = get(conn, wholesaler_path(conn, :edit, wholesaler.entry_id))
      assert html_response(conn, 200) =~ "Edit Wholesaler"
    end
  end

  describe "update wholesaler" do
    setup [:create_wholesaler, :admin_login]

    test "renders errors when data is invalid", %{conn: conn, wholesaler: wholesaler} do
      conn = put(conn, wholesaler_path(conn, :update, wholesaler.entry_id), venue: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Wholesaler"
    end
  end

  describe "add drinks to wholesaler - admin" do
    setup [:create_wholesaler, :admin_login]

    test "renders form for adding drinks to chosen wholesaler", %{
      conn: conn,
      wholesaler: wholesaler
    } do
      conn = get(conn, wholesaler_path(conn, :add_drinks, wholesaler.entry_id))
      assert html_response(conn, 200) =~ "Add drinks sold by the wholesaler"
    end
  end

  defp create_wholesaler(_) do
    wholesaler = fixture(:wholesaler)
    {:ok, wholesaler: wholesaler}
  end
end
