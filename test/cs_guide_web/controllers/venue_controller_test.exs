defmodule CsGuideWeb.VenueControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Resources, Categories}

  @create_types [
    %{
      name: "Beer"
    },
    %{
      name: "Wine"
    },
    %{
      name: "Soft Drink"
    }
  ]

  @create_brand %{
    name: "Brewdog",
    description: "Brewdog description",
    deleted: false
  }

  @create_drinks [
    %{
      entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055d",
      name: "Nanny State",
      abv: "0.5",
      description: "Description of Nanny State",
      weighting: 1,
      drink_types: %{"Beer" => "on"}
    },
    %{
      entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29a",
      name: "Shiraz",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Wine" => "on"}
    },
    %{
      entry_id: "587bee17-2034-4466-8396-d5277b1eee38",
      name: "Cucumber & Mint",
      abv: "0.0",
      description: "Description of drink",
      weighting: 1,
      drink_types: %{"Soft Drink" => "on"}
    }
  ]

  @create_attrs %{
    phone_number: "some phone_number",
    postcode: "some postcode",
    venue_name: "The Example Pub",
    venue_types: %{
      "35f9e338-7c50-4883-8214-91e2c0ad5796" => "on"
    },
    drinks: %{"0167ce54-95fc-4b28-82a2-147b7b67055d" => "on"}
  }
  @update_attrs %{
    phone_number: "some updated phone_number",
    postcode: "some updated postcode",
    venue_name: "The Updated Example Pub",
    venue_types: %{
      "35f9e338-7c50-4883-8214-91e2c0ad5796" => "on"
    },
    drinks: %{"0167ce54-95fc-4b28-82a2-147b7b67055d" => "on"}
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

  describe "calculates correct Club Soda Score" do
    setup [:drink_setup]

    test "score should be 1", %{conn: conn, drinks: drinks} do
      drink = Enum.find(drinks, fn d -> d.name == "Nanny State" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{"drinks" => Map.new([{drink.entry_id, "on"}])}
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.0"
    end

    test "score should be 1.5", %{conn: conn, drinks: drinks} do
      nannyState = Enum.find(drinks, fn d -> d.name == "Nanny State" end)
      nixKix = Enum.find(drinks, fn d -> d.name == "Cucumber & Mint" end)

      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)
      assert %{id: id} = redirected_params(conn)

      conn =
        put(conn, venue_path(conn, :update, id), %{
          "id" => id,
          "venue" => %{
            "drinks" => Map.new([{nannyState.entry_id, "on"}, {nixKix.entry_id, "on"}])
          }
        })

      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Club Soda Score of 1.5"
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

    test "redirects when data is valid", %{conn: conn, venue: venue} do
      conn = put(conn, venue_path(conn, :update, venue.entry_id), venue: @update_attrs)
      assert redirected_to(conn) == venue_path(conn, :show, venue.entry_id)

      conn = get(conn, venue_path(conn, :show, venue.entry_id))
      assert html_response(conn, 200) =~ "some updated phone_number"
    end

    test "renders errors when data is invalid", %{conn: conn, venue: venue} do
      conn = put(conn, venue_path(conn, :update, venue.entry_id), venue: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Venue"
    end
  end

  #   describe "delete venue" do
  #     setup [:create_venue]
  #
  #     test "deletes chosen venue", %{conn: conn, venue: venue} do
  #       conn = delete(conn, venue_path(conn, :delete, venue))
  #       assert redirected_to(conn) == venue_path(conn, :index)
  #
  #       assert_error_sent(404, fn ->
  #         get(conn, venue_path(conn, :show, venue))
  #       end)
  #     end
  #   end
  #
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
