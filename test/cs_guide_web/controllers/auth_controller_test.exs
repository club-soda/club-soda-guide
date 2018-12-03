defmodule CsGuideWeb.AuthControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Accounts

  def create_user(_) do
    {:ok, user} = Accounts.User.insert(%{email: "test@email", password: "password"})
    {:ok, user: user}
  end

  describe "log in" do
    setup [:create_user]

    test "login page", %{conn: conn} do
      conn = get(conn, session_path(conn, :new))
      assert html_response(conn, 200) =~ "Admin Login"
    end

    test "login", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), email: "test@email", password: "password")

      assert redirected_to(conn, 302) =~ "/admin"
    end
  end
end
