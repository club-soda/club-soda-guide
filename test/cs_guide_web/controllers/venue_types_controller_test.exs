defmodule CsGuideWeb.VenueTypesControllerTest do
  use CsGuideWeb.ConnCase

  import CsGuide.SetupHelpers

  alias CsGuide.Categories.VenueType

  @create_attrs %{name: "some type"}
  @update_attrs %{name: "some updated type"}
  @invalid_attrs %{name: nil}

  def fixture(:venue_types) do
    {:ok, venue_types} = %VenueType{} |> VenueType.changeset(@create_attrs) |> VenueType.insert()
    venue_types
  end

  describe "index" do
    test "does not list venue_types if not logged in", %{conn: conn} do
      conn = get(conn, venue_type_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all venue_type", %{conn: conn} do
      conn = get(conn, venue_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Venue Types"
    end
  end

  describe "new venue_types" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, venue_type_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new venue_types - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, venue_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Venue types"
    end
  end

  describe "create venue_types" do
    setup [:admin_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, venue_type_path(conn, :create), venue_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == venue_type_path(conn, :show, id)

      conn = get(conn, venue_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Venue types"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, venue_type_path(conn, :create), venue_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Venue types"
    end
  end

  describe "edit venue_types" do
    setup [:create_venue_types]

    test "does not render form when not logged in", %{conn: conn, venue_type: venue_types} do
      conn = get(conn, venue_type_path(conn, :edit, venue_types.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit venue_types - admin" do
    setup [:create_venue_types, :admin_login]

    test "renders form for editing chosen venue_types", %{conn: conn, venue_type: venue_types} do
      conn = get(conn, venue_type_path(conn, :edit, venue_types.entry_id))
      assert html_response(conn, 200) =~ "Edit Venue type"
    end
  end

  describe "update venue_types" do
    setup [:create_venue_types, :admin_login]

    test "redirects when data is valid", %{conn: conn, venue_type: venue_types} do
      conn =
        put(conn, venue_type_path(conn, :update, venue_types.entry_id), venue_type: @update_attrs)

      assert redirected_to(conn) == venue_type_path(conn, :show, venue_types.entry_id)

      conn = get(conn, venue_type_path(conn, :show, venue_types.entry_id))
      assert html_response(conn, 200) =~ "some updated type"
    end

    test "renders errors when data is invalid", %{conn: conn, venue_type: venue_types} do
      conn =
        put(conn, venue_type_path(conn, :update, venue_types.entry_id), venue_type: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Venue type"
    end
  end

  defp create_venue_types(_) do
    venue_types = fixture(:venue_types)
    {:ok, venue_type: venue_types}
  end
end
