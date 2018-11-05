defmodule CsGuideWeb.DrinkControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.{Resources, Categories}

  @create_attrs %{
    entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055a",
    name: "AF Beer 1",
    abv: "0.5",
    description: "Description of drink",
    weighting: 1,
    drink_types: %{"Beer" => "on"}
  }
  @update_attrs %{
    entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055a",
    name: "Updated AF Beer 1",
    abv: "0.5",
    description: "Updated description of drink",
    weighting: 1,
    drink_types: %{"Beer" => "on"}
  }

  @create_brand %{
    name: "Brewdog",
    description: "Brewdog description",
    deleted: false
  }

  @create_types [
    %{
      name: "Beer"
    },
    %{
      name: "Wine"
    }
  ]

  def fixture(:type) do
    types =
      @create_types
      |> Enum.map(fn t ->
        {:ok, type} = Categories.DrinkType.insert(t)
        type
      end)

    types
  end

  def fixture(:brand) do
    {:ok, brand} =
      @create_brand
      |> Resources.Brand.insert()

    brand
  end

  def fixture(:drink, brand) do
    {:ok, drink} =
      @create_attrs
      |> Map.put(:brand, Map.new([{brand, "on"}]))
      |> Resources.Drink.insert()

    drink
  end

  describe "index" do
    test "lists all drinks", %{conn: conn} do
      conn = get(conn, drink_path(conn, :index))
      assert html_response(conn, 200) =~ "All Drinks"
    end
  end

  describe "new drink" do
    test "renders form", %{conn: conn} do
      conn = get(conn, drink_path(conn, :new))
      assert html_response(conn, 200) =~ "New Drink"
    end
  end

  describe "edit drink" do
    setup [:drink_setup]

    test "renders form for editing chosen drink", %{conn: conn, drink: drink} do
      conn = get(conn, drink_path(conn, :edit, drink.entry_id))
      assert html_response(conn, 200) =~ "Edit Drink"
    end
  end

  describe "update drink" do
    setup [:drink_setup]

    test "redirects when data is valid", %{conn: conn, drink: drink} do
      conn = put(conn, drink_path(conn, :update, drink.entry_id), drink: @update_attrs)
      assert redirected_to(conn) == drink_path(conn, :index)

      conn = get(conn, drink_path(conn, :show, drink.entry_id))
      assert html_response(conn, 200) =~ "Updated AF Beer 1"
    end
  end

  defp drink_setup(_) do
    brand = fixture(:brand)
    {:ok, brand: brand}

    type = fixture(:type)
    {:ok, type: type}

    drink = fixture(:drink, brand.name)
    {:ok, drink: drink}
  end
end
