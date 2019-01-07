defmodule CsGuideWeb.VenueControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.Fixtures
  alias CsGuide.{Resources, Categories}
  alias CsGuideWeb.VenueController
  alias CsGuide.Resources.Venue

  import CsGuide.SetupHelpers

  @spirits_premixed "Spirits and Premixed"

  @create_brand Fixtures.create_brand()
  @create_types Fixtures.create_types()
  @create_drinks Fixtures.create_drinks()
  @create_venue_types Fixtures.create_venue_types()

  @create_attrs %{
    address: "number and road",
    city: "London",
    phone_number: "01234567890",
    postcode: "EC1 5AD",
    venue_name: "The Example Pub",
    drinks: %{"AF Beer 1" => "on"},
    venue_types: %{"Bars" => "on"}
  }
  @update_attrs %{
    phone_number: "09876543210",
    postcode: "EC2 7FY",
    venue_name: "The Updated Example Pub",
    drinks: %{"AF Beer 1" => "on"},
    venue_types: %{"Bars" => "on"}
  }
  @invalid_attrs %{phone_number: nil, postcode: nil, venue_name: nil}

  def fixture(:venue) do
    @create_venue_types
    |> Enum.map(fn vt ->
      {:ok, venue_type} =
        %Categories.VenueType{}
        |> Categories.VenueType.changeset(vt)
        |> Categories.VenueType.insert()
    end)

    {:ok, venue} =
      @create_attrs
      |> Resources.Venue.insert()

    venue
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

  def fixture(:brand) do
    {:ok, brand} =
      %Resources.Brand{}
      |> Resources.Brand.changeset(@create_brand)
      |> Resources.Brand.insert()

    brand
  end

  def fixture(:type) do
    types =
      @create_types
      |> Enum.map(fn t ->
        {:ok, type} =
          %Categories.DrinkType{}
          |> Categories.DrinkType.changeset(t)
          |> Categories.DrinkType.insert()

        type
      end)

    types
  end

  describe "index" do
    test "does not list venues if not logged in", %{conn: conn} do
      conn = get(conn, venue_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all venues", %{conn: conn} do
      conn = get(conn, venue_path(conn, :index))
      assert html_response(conn, 200) =~ "All Venues"
    end
  end

  describe "new venue" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, venue_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new venue - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, venue_path(conn, :new))
      assert html_response(conn, 200) =~ "New Venue"
    end
  end

  describe "create venue" do
    setup [:create_venue, :admin_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)

      assert %{unique_name: unique_name} = redirected_params(conn)
      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "The Example Pub"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, venue_path(conn, :create), venue: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Venue"
    end
  end

  describe "Calculates correct CS Score:" do
    setup [:drink_setup, :create_venue, :admin_login]

    test "When no drinks are added the score is 0", %{conn: conn, drinks: drinks} do
      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      name = VenueController.get_name(unique_name)
      postcode = VenueController.get_postcode(unique_name)

      venue =
        Venue.get_by([venue_name: name, postcode: postcode], case_insensitive: true)
        |> Venue.preload(:venue_types)

      conn =
        put(conn, venue_path(conn, :update, venue.entry_id), %{
          "unique_name" => venue.entry_id,
          "venue" => %{
            "drinks" => Map.new([])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 0.0"
    end

    test "AF Beers and Ciders are worth 1pt each", %{conn: conn, drinks: drinks} do
      afBeer1 = Enum.find(drinks, fn d -> d.name == "AF Beer 1" end)
      afBeer2 = Enum.find(drinks, fn d -> d.name == "AF Beer 2" end)
      afWine1 = Enum.find(drinks, fn d -> d.name == "AF Wine 1" end)
      afWine2 = Enum.find(drinks, fn d -> d.name == "AF Wine 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {afBeer1.entry_id, "on"},
                {afBeer2.entry_id, "on"},
                {afWine1.entry_id, "on"},
                {afWine2.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 4.0"
    end

    test "Low Alc Beers can be max 1pt", %{conn: conn, drinks: drinks} do
      beer1 = Enum.find(drinks, fn d -> d.name == "Low Alc Beer 1" end)
      beer2 = Enum.find(drinks, fn d -> d.name == "Low Alc Beer 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {beer1.entry_id, "on"},
                {beer2.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "Low Alc Wines can be max 1pt", %{conn: conn, drinks: drinks} do
      wine1 = Enum.find(drinks, fn d -> d.name == "Low Alc Wine 1" end)
      wine2 = Enum.find(drinks, fn d -> d.name == "Low Alc Wine 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {wine1.entry_id, "on"},
                {wine2.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "3 soft drinks are worth 1pt", %{conn: conn, drinks: drinks} do
      softDrink1 = Enum.find(drinks, fn d -> d.name == "Soft Drink 1" end)
      softDrink2 = Enum.find(drinks, fn d -> d.name == "Soft Drink 2" end)
      softDrink3 = Enum.find(drinks, fn d -> d.name == "Soft Drink 3" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {softDrink1.entry_id, "on"},
                {softDrink2.entry_id, "on"},
                {softDrink3.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "3 Tonics/Mixers are worth 1pt", %{conn: conn, drinks: drinks} do
      tonic1 = Enum.find(drinks, fn d -> d.name == "Tonic 1" end)
      mixer1 = Enum.find(drinks, fn d -> d.name == "Mixer 1" end)
      mixer2 = Enum.find(drinks, fn d -> d.name == "Mixer 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {tonic1.entry_id, "on"},
                {mixer1.entry_id, "on"},
                {mixer2.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "Scores are capped at 5pts", %{conn: conn, drinks: drinks} do
      afWine1 = Enum.find(drinks, fn d -> d.name == "AF Wine 1" end)
      afWine2 = Enum.find(drinks, fn d -> d.name == "AF Wine 2" end)
      lowAlcWine1 = Enum.find(drinks, fn d -> d.name == "Low Alc Wine 1" end)
      afBeer1 = Enum.find(drinks, fn d -> d.name == "AF Beer 1" end)
      afBeer2 = Enum.find(drinks, fn d -> d.name == "AF Beer 2" end)
      afCider1 = Enum.find(drinks, fn d -> d.name == "AF Cider 1" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {afWine1.entry_id, "on"},
                {afWine2.entry_id, "on"},
                {lowAlcWine1.entry_id, "on"},
                {afBeer1.entry_id, "on"},
                {afBeer2.entry_id, "on"},
                {afCider1.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 5.0"
    end

    test "Spirits and Premixed are worth 1pt each", %{conn: conn, drinks: drinks} do
      spirit1 = Enum.find(drinks, fn d -> d.name == "Spirit 1" end)
      premixed1 = Enum.find(drinks, fn d -> d.name == "Premixed 1" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {spirit1.entry_id, "on"},
                {premixed1.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 2.0"
    end

    test "AF Ciders are worth 1pt each", %{conn: conn, drinks: drinks} do
      afCider1 = Enum.find(drinks, fn d -> d.name == "AF Cider 1" end)
      afCider2 = Enum.find(drinks, fn d -> d.name == "AF Cider 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{unique_name: unique_name} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, unique_name), %{
          "unique_name" => unique_name,
          "venue" => %{
            "drinks" =>
              Map.new([
                {afCider1.entry_id, "on"},
                {afCider2.entry_id, "on"}
              ]),
            "num_cocktails" => 0
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, unique_name)

      conn = get(conn, venue_path(conn, :show, unique_name))
      assert html_response(conn, 200) =~ "Club Soda Score of 2.0"
    end
  end

  describe "edit venue" do
    setup [:create_venue]

    test "does not render form when not logged in", %{conn: conn, venue: venue} do
      unique_name = venue.venue_name <> " " <> venue.postcode

      conn = get(conn, venue_path(conn, :edit, unique_name))
      assert html_response(conn, 302)
    end
  end

  describe "edit venue - admin" do
    setup [:create_venue, :admin_login]

    test "renders form for editing chosen venue", %{conn: conn, venue: venue} do
      unique_name = venue.venue_name <> " " <> venue.postcode

      conn = get(conn, venue_path(conn, :edit, unique_name))
      assert html_response(conn, 200) =~ "Edit Venue"
    end
  end

  describe "update venue" do
    setup [:create_venue, :admin_login]

    test "renders errors when data is invalid", %{conn: conn, venue: venue} do
      conn = put(conn, venue_path(conn, :update, venue.entry_id), venue: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Venue"
    end
  end

  defp create_venue(_) do
    venue = fixture(:venue)
    {:ok, venue: venue}
  end

  defp drink_setup(_) do
    brand = fixture(:brand)
    {:ok, brand: brand}

    type = fixture(:type)
    {:ok, type: type}

    drinks = fixture(:drink, brand.name)
    {:ok, drinks: drinks}
  end
end
