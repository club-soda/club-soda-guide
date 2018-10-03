defmodule CsGuideWeb.DrinkControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Resources

  @create_attrs %{abv: 120.5, brand: "some brand", name: "some name"}
  @update_attrs %{abv: 456.7, brand: "some updated brand", name: "some updated name"}
  @invalid_attrs %{abv: nil, brand: nil, name: nil}

  def fixture(:drink) do
    {:ok, drink} = Resources.create_drink(@create_attrs)
    drink
  end

  describe "index" do
    test "lists all drinks", %{conn: conn} do
      conn = get conn, drink_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Drinks"
    end
  end

  describe "new drink" do
    test "renders form", %{conn: conn} do
      conn = get conn, drink_path(conn, :new)
      assert html_response(conn, 200) =~ "New Drink"
    end
  end

  describe "create drink" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, drink_path(conn, :create), drink: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == drink_path(conn, :show, id)

      conn = get conn, drink_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Drink"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, drink_path(conn, :create), drink: @invalid_attrs
      assert html_response(conn, 200) =~ "New Drink"
    end
  end

  describe "edit drink" do
    setup [:create_drink]

    test "renders form for editing chosen drink", %{conn: conn, drink: drink} do
      conn = get conn, drink_path(conn, :edit, drink)
      assert html_response(conn, 200) =~ "Edit Drink"
    end
  end

  describe "update drink" do
    setup [:create_drink]

    test "redirects when data is valid", %{conn: conn, drink: drink} do
      conn = put conn, drink_path(conn, :update, drink), drink: @update_attrs
      assert redirected_to(conn) == drink_path(conn, :show, drink)

      conn = get conn, drink_path(conn, :show, drink)
      assert html_response(conn, 200) =~ "some updated brand"
    end

    test "renders errors when data is invalid", %{conn: conn, drink: drink} do
      conn = put conn, drink_path(conn, :update, drink), drink: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Drink"
    end
  end

  describe "delete drink" do
    setup [:create_drink]

    test "deletes chosen drink", %{conn: conn, drink: drink} do
      conn = delete conn, drink_path(conn, :delete, drink)
      assert redirected_to(conn) == drink_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, drink_path(conn, :show, drink)
      end
    end
  end

  defp create_drink(_) do
    drink = fixture(:drink)
    {:ok, drink: drink}
  end
end
