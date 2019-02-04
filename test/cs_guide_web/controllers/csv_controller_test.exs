defmodule CsGuideWeb.CsvControllerTest do
  use CsGuideWeb.ConnCase
  import CsGuide.SetupHelpers

  describe "Export to csv" do
    setup [:admin_login]
    test "GET /csv?data=venues", %{conn: conn} do
      conn = get(conn, "/csv?data=venues")
      assert response(conn, 200)
    end

    test "GET /csv?data=drinks", %{conn: conn} do
      conn = get(conn, "/csv?data=drinks")
      assert response(conn, 200)
    end

    test "GET /csv?data=brands", %{conn: conn} do
      conn = get(conn, "/csv?data=brands")
      assert response(conn, 200)
    end

    test "GET /csv?data=drink-types", %{conn: conn} do
      conn = get(conn, "/csv?data=drink-types")
      assert response(conn, 200)
    end

    test "GET /csv?data=drink-styles", %{conn: conn} do
      conn = get(conn, "/csv?data=drink-styles")
      assert response(conn, 200)
    end

    test "GET /csv?data=venue-types", %{conn: conn} do
      conn = get(conn, "/csv?data=venue-types")
      assert response(conn, 200)
    end

    test "GET /csv?data=venues-drinks", %{conn: conn} do
      conn = get(conn, "/csv?data=venue-drinks")
      assert response(conn, 200)
    end

    test "GET /csv?data=brands-drinks", %{conn: conn} do
      conn = get(conn, "/csv?data=brand-drinks")
      assert response(conn, 200)
    end

    test "GET /csv?data=wrong-data", %{conn: conn} do
      conn = get(conn, "/csv?data=wrong-data")
      assert response(conn, 404)
    end
  end
end
