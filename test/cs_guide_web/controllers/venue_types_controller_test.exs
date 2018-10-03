defmodule CsGuideWeb.VenueTypesControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Categories

  @create_attrs %{type: "some type"}
  @update_attrs %{type: "some updated type"}
  @invalid_attrs %{type: nil}

  def fixture(:venue_types) do
    {:ok, venue_types} = Categories.create_venue_types(@create_attrs)
    venue_types
  end

  describe "index" do
    test "lists all venue_type", %{conn: conn} do
      conn = get conn, venue_types_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Venue type"
    end
  end

  describe "new venue_types" do
    test "renders form", %{conn: conn} do
      conn = get conn, venue_types_path(conn, :new)
      assert html_response(conn, 200) =~ "New Venue types"
    end
  end

  describe "create venue_types" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, venue_types_path(conn, :create), venue_types: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == venue_types_path(conn, :show, id)

      conn = get conn, venue_types_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Venue types"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, venue_types_path(conn, :create), venue_types: @invalid_attrs
      assert html_response(conn, 200) =~ "New Venue types"
    end
  end

  describe "edit venue_types" do
    setup [:create_venue_types]

    test "renders form for editing chosen venue_types", %{conn: conn, venue_types: venue_types} do
      conn = get conn, venue_types_path(conn, :edit, venue_types)
      assert html_response(conn, 200) =~ "Edit Venue types"
    end
  end

  describe "update venue_types" do
    setup [:create_venue_types]

    test "redirects when data is valid", %{conn: conn, venue_types: venue_types} do
      conn = put conn, venue_types_path(conn, :update, venue_types), venue_types: @update_attrs
      assert redirected_to(conn) == venue_types_path(conn, :show, venue_types)

      conn = get conn, venue_types_path(conn, :show, venue_types)
      assert html_response(conn, 200) =~ "some updated type"
    end

    test "renders errors when data is invalid", %{conn: conn, venue_types: venue_types} do
      conn = put conn, venue_types_path(conn, :update, venue_types), venue_types: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Venue types"
    end
  end

  describe "delete venue_types" do
    setup [:create_venue_types]

    test "deletes chosen venue_types", %{conn: conn, venue_types: venue_types} do
      conn = delete conn, venue_types_path(conn, :delete, venue_types)
      assert redirected_to(conn) == venue_types_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, venue_types_path(conn, :show, venue_types)
      end
    end
  end

  defp create_venue_types(_) do
    venue_types = fixture(:venue_types)
    {:ok, venue_types: venue_types}
  end
end
