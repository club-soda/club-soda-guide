defmodule CsGuideWeb.SearchDrinkControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Resources, Categories, Fixtures}

  @create_types Fixtures.create_types()
  @create_brand Fixtures.create_brand()

  @create_attrs %{
    name: "AF Beer 1",
    abv: "0.5",
    description: "Description of drink",
    weighting: 1,
    drink_types: %{"Beer" => "on"}
  }

  describe "Search drink" do
    setup [:drink_setup]

    test "GET /search/drinks with term", %{conn: conn} do
      conn = get(conn, "/search/drinks?term=beer")
      assert html_response(conn, 200) =~ "AF Beer 1"
    end
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

  def fixture(:brand) do
    {:ok, brand} =
      %Resources.Brand{}
      |> Resources.Brand.changeset(@create_brand)
      |> Resources.Brand.insert()

    brand
  end

  def fixture(:drink, brand) do
    {:ok, drink} =
      @create_attrs
      |> Map.put(:brand, brand)
      |> Resources.Drink.insert()

    drink
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
