defmodule CsGuideWeb.Plugs.CookieTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Accounts.User

  @user_params %{
    email: "venue@owner",
    role: "venue_admin",
    password: "test",
    verified: NaiveDateTime.utc_now()
  }

  describe "testing cookie plug" do
    test "No user logged in shows popup", %{conn: conn} do
      conn = get(conn, page_path(conn, :index))
      assert html_response(conn, 200) =~ "This website uses cookies"
    end

    test "Pop up does not display if user clicks 'Got it!'", %{conn: conn} do
      # landing page
      conn = get(conn, page_path(conn, :index))
      assert html_response(conn, 200) =~ "This website uses cookies"

      # clicking 'Got it!'
      conn = post(conn, cookie_path(conn, :accept_cookies, "/"))
      assert redirected_to(conn) == page_path(conn, :index)

      # back on landing page
      conn = get(conn, page_path(conn, :index))
      refute html_response(conn, 200) =~ "This website uses cookies"
    end

    test "Pop up does not display if user is verified", %{conn: conn} do
      {:ok, user} =
        %User{}
        |> User.changeset(@user_params)
        |> User.insert()

      conn = post(conn, session_path(conn, :create), %{email: user.email, password: "test"})

      conn = get(conn, page_path(conn, :index))
      refute html_response(conn, 200) =~ "This website uses cookies"
    end

    test "Pop up displays if user is logged in but not verified", %{conn: conn} do
      user_params = Map.put(@user_params, :verified, nil)

      {:ok, user} =
        %User{}
        |> User.changeset(user_params)
        |> User.insert()

      conn = post(conn, session_path(conn, :create), %{email: user.email, password: "test"})

      conn = get(conn, page_path(conn, :index))
      assert html_response(conn, 200) =~ "This website uses cookies"
    end
  end
end