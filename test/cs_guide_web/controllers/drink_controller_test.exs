defmodule CsGuideWeb.DrinkControllerTest do
  use CsGuideWeb.ConnCase

  import CsGuide.SetupHelpers

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
  @update_attrs %{
    name: "Updated AF Beer 1",
    abv: "0.5",
    description: "Updated description of drink",
    weighting: 1,
    drink_types: %{"Beer" => "on"}
  }

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

  describe "index" do
    test "cannot access page if not logged in", %{conn: conn} do
      conn = get(conn, drink_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all drinks", %{conn: conn} do
      conn = get(conn, drink_path(conn, :index))
      assert html_response(conn, 200) =~ "All Drinks"
    end
  end

  describe "new drink" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, drink_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new drink - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, drink_path(conn, :new))
      assert html_response(conn, 200) =~ "New Drink"
    end
  end

  describe "create drink - admin" do
    setup [:admin_login]

    test "redirects back to new if drink does not contain abv", %{conn: conn} do
      conn = post(conn, drink_path(conn, :create), drink: %{name: "new drink"})
      assert html_response(conn, 200) =~ "New Drink"
    end

    test "creates drink if details are correct", %{conn: conn} do
      conn = post(conn, drink_path(conn, :create), drink: @create_attrs)
      assert redirected_to(conn) == drink_path(conn, :index)

      conn = get(conn, drink_path(conn, :index))
      assert html_response(conn, 200) =~ "AF Beer 1"
    end
  end

  describe "edit drink" do
    setup [:drink_setup]

    test "does not render form if not logged in", %{conn: conn, drink: drink} do
      conn = get(conn, drink_path(conn, :edit, drink.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit drink - admin" do
    setup [:drink_setup, :admin_login]

    test "renders form for editing chosen drink", %{conn: conn, drink: drink} do
      conn = get(conn, drink_path(conn, :edit, drink.entry_id))
      assert html_response(conn, 200) =~ "Edit Drink"
    end
  end

  describe "update drink" do
    setup [:drink_setup, :admin_login]

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
