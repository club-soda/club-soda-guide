defmodule CsGuideWeb.VenueControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.Resources

  @create_brand %{
    name: "Brewdog",
    description: "Brewdog description",
    deleted: false
  }

  @create_drink %{
    entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055d",
    name: "Nanny State",
    abv: "0.0",
    description: "Description of Nanny State",
    weighting: 1,
    drink_types: %{"cee2b342-8a5d-4a2f-931c-d139ee1d5fc0" => "on"}
  }

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

  def fixture(:drink, id) do
    {:ok, drink} =
      @create_drink
      |> Map.put(:brand, id)
      |> IO.inspect()
      |> Resources.Drink.insert()

    drink
  end

  def fixture(:brand) do
    {:ok, brand} =
      @create_brand
      |> Resources.Brand.insert()

    brand
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
    setup [:create_brand_and_drink]

    test "score should be 1", %{conn: conn} do
      conn = post(conn, venue_path(conn, :create), venue: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == venue_path(conn, :show, id)

      conn = get(conn, venue_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Nanny State"
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

  defp create_brand_and_drink(_) do
    brand = fixture(:brand)
    {:ok, brand: brand}

    drink = fixture(:drink, brand.id)
    {:ok, drink: drink}
  end
end
