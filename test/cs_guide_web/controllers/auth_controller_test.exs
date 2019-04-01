defmodule CsGuideWeb.AuthControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Accounts.User

  def create_user(_) do
    {:ok, user} =
      %User{}
      |> User.changeset(%{email: "test@email", password: "password"})
      |> User.insert()

    {:ok, user: user}
  end

  def create_admin(_) do
    {:ok, user} =
      %User{}
      |> User.changeset(%{email: "admin@email", password: "password", role: :site_admin})
      |> User.insert()

    {:ok, user: user}
  end

  describe "log in" do
    setup [:create_user, :create_admin]

    test "login page", %{conn: conn} do
      conn = get(conn, session_path(conn, :new))
      assert html_response(conn, 200) =~ "Admin Login"
    end

    test "redirects to home", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), email: "test@email", password: "password")

      assert redirected_to(conn, 302) =~ "/"
    end

    test "redirects to admin", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), email: "admin@email", password: "password")

      assert redirected_to(conn, 302) =~ "/admin"
    end
  end

  describe "log out" do
    setup [:create_user]

    test "log out redirected user back to home page", %{conn: conn, user: user} do
      conn = post(conn, session_path(conn, :create), email: "test@email", password: "password")
      assert redirected_to(conn, 302) =~ "/"

      conn = get(conn, page_path(conn, :index))
      assert html_response(conn, 200) =~ "Log out"
      assert conn.assigns.current_user != nil

      conn = delete(conn, session_path(conn, :delete, user.entry_id))
      assert redirected_to(conn, 302) =~ "/"

      conn = get(conn, page_path(conn, :index))
      assert conn.assigns.current_user == nil
      refute html_response(conn, 200) =~ "Log out"
    end
  end
end
