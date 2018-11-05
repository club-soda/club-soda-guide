defmodule CsGuideWeb.PageControllerTest do
  use CsGuideWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "The best low and no alcohol drinks and where to find them"
  end
end
