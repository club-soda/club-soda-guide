defmodule CsGuideWeb.VenueControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Resources, Categories}

  @spirit "Spirit"
  @premixed "Premixed"

  @create_types [
    %{
      name: "Beer"
    },
    %{
      name: "Wine"
    },
    %{
      name: "Soft Drink"
    },
    %{
      name: "Tonic"
    },
    %{
      name: "Mixer"
    },
    %{
      name: @spirit
    },
    %{
      name: @premixed
    },
    %{
      name: "Cider"
    }
  ]

  @create_brand %{
    name: "Brewdog",
    description: "Brewdog description",
    deleted: false
  }

  @create_drinks [
    %{
      entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055a",
      name: "AF Beer 1",
      abv: "0.5",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Beer" => "on"}
    },
    %{
      entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055b",
      name: "AF Beer 2",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Beer" => "on"}
    },
    %{
      entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055c",
      name: "Low Alc Beer 1",
      abv: "1.5",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Beer" => "on"}
    },
    %{
      entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055d",
      name: "Low Alc Beer 2",
      abv: "1.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Beer" => "on"}
    },
    %{
      entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29a",
      name: "AF Wine 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Wine" => "on"}
    },
    %{
      entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29b",
      name: "AF Wine 2",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Wine" => "on"}
    },
    %{
      entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29a",
      name: "Low Alc Wine 1",
      abv: "7.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Wine" => "on"}
    },
    %{
      entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29b",
      name: "Low Alc Wine 2",
      abv: "1.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Wine" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee31",
      name: "Soft Drink 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Soft Drink" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee32",
      name: "Soft Drink 2",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Soft Drink" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee33",
      name: "Soft Drink 3",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Soft Drink" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee21",
      name: "AF Cider 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Cider" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee22",
      name: "AF Cider 2",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Cider" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee41",
      name: "Tonic 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Tonic" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee42",
      name: "Mixer 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Mixer" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee43",
      name: "Mixer 2",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Mixer" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee51",
      name: "Spirit 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{@spirit => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee52",
      name: "Premixed 1",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{@premixed => "on"}
    }
  ]

  @create_attrs %{
    phone_number: "some phone_number",
    postcode: "some postcode",
    venue_name: "The Example Pub",
    venue_types: %{
      "35f9e338-7c50-4883-8214-91e2c0ad5796" => "on"
    },
    drinks: %{"AF Beer 1" => "on"}
  }
  @update_attrs %{
    phone_number: "some updated phone_number",
    postcode: "some updated postcode",
    venue_name: "The Updated Example Pub",
    drinks: %{"AF Beer 1" => "on"}
  }
  @invalid_attrs %{phone_number: nil, postcode: nil, venue_name: nil}

  def fixture(:venue) do
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
          Map.put(d, :brand, Map.new([{brand, "on"}]))
          |> Resources.Drink.insert()

        drink
      end)

    drinks
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

  describe "index" do
    test "lists all venues", %{conn: conn} do
      conn = get(conn, venue_path(conn, :index))
      assert html_response(conn, 200) =~ "All Venues"
    end
  end

  describe "new venue" do
    test "renders form", %{conn: conn} do
      conn = get(conn, venue_path(conn, :new))
      assert html_response(conn, 200) =~ "New Venue"
    end
  end

  describe "create venue" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "The Example Pub"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, venue_path(conn, :create), venue: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Venue"
    end
  end

  describe "Calculates correct CS Score:" do
    setup [:drink_setup]

    test "When no drinks are added the score is 0", %{conn: conn, drinks: drinks} do
      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" => Map.new([])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 0.0"
    end

    test "AF Beers and Ciders are worth 1pt each", %{conn: conn, drinks: drinks} do
      afBeer1 = Enum.find(drinks, fn d -> d.name == "AF Beer 1" end)
      afBeer2 = Enum.find(drinks, fn d -> d.name == "AF Beer 2" end)
      afWine1 = Enum.find(drinks, fn d -> d.name == "AF Wine 1" end)
      afWine2 = Enum.find(drinks, fn d -> d.name == "AF Wine 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {afBeer1.entry_id, "on"},
                {afBeer2.entry_id, "on"},
                {afWine1.entry_id, "on"},
                {afWine2.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 4.0"
    end

    test "Low Alc Beers can be max 1pt", %{conn: conn, drinks: drinks} do
      beer1 = Enum.find(drinks, fn d -> d.name == "Low Alc Beer 1" end)
      beer2 = Enum.find(drinks, fn d -> d.name == "Low Alc Beer 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {beer1.entry_id, "on"},
                {beer2.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "Low Alc Wines can be max 1pt", %{conn: conn, drinks: drinks} do
      wine1 = Enum.find(drinks, fn d -> d.name == "Low Alc Wine 1" end)
      wine2 = Enum.find(drinks, fn d -> d.name == "Low Alc Wine 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {wine1.entry_id, "on"},
                {wine2.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "3 soft drinks are worth 1pt", %{conn: conn, drinks: drinks} do
      softDrink1 = Enum.find(drinks, fn d -> d.name == "Soft Drink 1" end)
      softDrink2 = Enum.find(drinks, fn d -> d.name == "Soft Drink 2" end)
      softDrink3 = Enum.find(drinks, fn d -> d.name == "Soft Drink 3" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {softDrink1.entry_id, "on"},
                {softDrink2.entry_id, "on"},
                {softDrink3.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "3 Tonics/Mixers are worth 1pt", %{conn: conn, drinks: drinks} do
      tonic1 = Enum.find(drinks, fn d -> d.name == "Tonic 1" end)
      mixer1 = Enum.find(drinks, fn d -> d.name == "Mixer 1" end)
      mixer2 = Enum.find(drinks, fn d -> d.name == "Mixer 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {tonic1.entry_id, "on"},
                {mixer1.entry_id, "on"},
                {mixer2.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "Scores are capped at 5pts", %{conn: conn, drinks: drinks} do
      afWine1 = Enum.find(drinks, fn d -> d.name == "AF Wine 1" end)
      afWine2 = Enum.find(drinks, fn d -> d.name == "AF Wine 2" end)
      lowAlcWine1 = Enum.find(drinks, fn d -> d.name == "Low Alc Wine 1" end)
      afBeer1 = Enum.find(drinks, fn d -> d.name == "AF Beer 1" end)
      afBeer2 = Enum.find(drinks, fn d -> d.name == "AF Beer 2" end)
      # lowAlcBeer1 = Enum.find(drinks, fn d -> d.name == "Low Alc Beer 1" end)
      afCider1 = Enum.find(drinks, fn d -> d.name == "AF Cider 1" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {afWine1.entry_id, "on"},
                {afWine2.entry_id, "on"},
                {lowAlcWine1.entry_id, "on"},
                {afBeer1.entry_id, "on"},
                {afBeer2.entry_id, "on"},
                {afCider1.entry_id, "on"}
                # {lowAlcBeer1.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 5.0"
    end

    test "Spirits and Premixed are worth 1pt each", %{conn: conn, drinks: drinks} do
      spirit1 = Enum.find(drinks, fn d -> d.name == "Spirit 1" end)
      premixed1 = Enum.find(drinks, fn d -> d.name == "Premixed 1" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {spirit1.entry_id, "on"},
                {premixed1.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 2.0"
    end

    test "AF Ciders are worth 1pt each", %{conn: conn, drinks: drinks} do
      afCider1 = Enum.find(drinks, fn d -> d.name == "AF Cider 1" end)
      afCider2 = Enum.find(drinks, fn d -> d.name == "AF Cider 2" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" =>
              Map.new([
                {afCider1.entry_id, "on"},
                {afCider2.entry_id, "on"}
              ])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 2.0"
    end
  end

  describe "edit venue" do
    setup [:create_venue]

    test "renders form for editing chosen venue", %{conn: conn, venue: venue} do
      conn = get(conn, venue_path(conn, :edit, venue.entry_id))
      assert html_response(conn, 200) =~ "Edit Venue"
    end
  end

  describe "update venue" do
    setup [:create_venue]

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
