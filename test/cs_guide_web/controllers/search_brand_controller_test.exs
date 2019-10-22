defmodule CsGuideWeb.SearchBrandControllerTest do
  use CsGuideWeb.ConnCase

  describe "Search brands" do
    test "GET /search/brands", %{conn: conn} do
      conn = get(conn, "/search/brands")
      assert html_response(conn, 200)
    end
  end

end
