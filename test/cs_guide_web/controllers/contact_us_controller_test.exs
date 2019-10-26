defmodule CsGuideWeb.ContactUsControllerTest do
  use CsGuideWeb.ConnCase

  describe "Display contact us page" do
    test "GET /contact-us/new", %{conn: conn} do
      conn = get(conn, "/contact-us/new")
      assert html_response(conn, 200)
    end
  end

end
