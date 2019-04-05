defmodule CsGuideWeb.PasswordControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Accounts.User
  import CsGuide.SetupHelpers

  @valid_user_email %{user: %{email: "good@user"}}
  @invalid_user_email %{user: %{email: "bad@user"}}

  # inserts an admin user into the testing db
  def user_with_valid_token(_) do
    {:ok, user} =
      %User{}
      |> User.changeset(%{email: "good@user", password: "password", role: :site_admin})
      |> User.insert()

    user = User.reset_password_token(user, 86400)

    {:ok, user: user}
  end

  test "get /password/new", %{conn: conn} do
    conn = get(conn, password_path(conn, :new))
    assert html_response(conn, 200) =~ "Forgotten Password"
  end

  describe "Valid flows" do
    setup [:user_with_valid_token]

    test "post /password redirects", %{conn: conn} do
      conn = post(conn, password_path(conn, :create), @valid_user_email)
      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "post /password updates users password reset token", %{conn: conn, user: user} do
      post(conn, password_path(conn, :create), @valid_user_email)
      updated_user = User.get(user.entry_id)
      refute updated_user.password_reset_token == user.password_reset_token
    end

    test "get /password/:token/edit when user has valid token", %{conn: conn, user: user} do
      conn = get(conn, password_path(conn, :edit, user.password_reset_token))
      assert html_response(conn, 200) =~ "Set password"
    end

    test "put /password when user has valid token redirects user and logs them in", %{conn: conn, user: user} do
      user_params =
        @valid_user_email.user
        |> Map.put(:password, "test-password")
        |> Map.put(:password_confirmation, "test-password")

      conn = put(conn, password_path(conn, :update, user.password_reset_token), user: user_params)
      assert get_flash(conn, :info) == "Password updated"
      assert redirected_to(conn) == page_path(conn, :index)

      conn = get(conn, page_path(conn, :index))
      assert conn.assigns.current_user.id == user.id
    end

    test "put /password when user has valid token but when a another user is logged in", %{conn: conn, user: user} do
      %User{}
      |> User.changeset(%{email: "other@user", password: "password", role: :site_admin})
      |> User.insert()

      # logs in another user
      conn = post(conn, session_path(conn, :create, email: "other@user", password: "password"))

      user_params =
        @valid_user_email.user
        |> Map.put(:password, "test-password")
        |> Map.put(:password_confirmation, "test-password")

      conn = put(conn, password_path(conn, :update, user.password_reset_token), user: user_params)
      assert get_flash(conn, :info) == "Password updated"
      assert redirected_to(conn) == page_path(conn, :index)

      conn = get(conn, page_path(conn, :index))
      refute conn.assigns.current_user.id == user.id
    end
  end

  describe "Invalid flows" do
    setup [:user_with_valid_token]

    test "post /password redirects back to password new", %{conn: conn} do
      conn = post(conn, password_path(conn, :create), @invalid_user_email)
      assert redirected_to(conn) == password_path(conn, :new)
    end

    test "get /password/:token/edit when token invalid", %{conn: conn} do
      conn = get(conn, password_path(conn, :edit, "bad-token"))
      assert redirected_to(conn) == password_path(conn, :new)
      assert get_flash(conn, :error) == "Invalid password reset token"
    end

    test "get /password/:token/edit when user is correct but token has expired", %{conn: conn, user: user} do
      user = User.reset_password_token(user, -86400) # makes the users token expired
      conn = get(conn, password_path(conn, :edit, user.password_reset_token))
      assert redirected_to(conn) == password_path(conn, :new)
      assert get_flash(conn, :error) == "Password reset token has expired"
    end

    test "put /password when user has expired token redirects user", %{conn: conn, user: user} do
      user = User.reset_password_token(user, -86400) # makes the users token expired
      user_params =
        @valid_user_email.user
        |> Map.put(:password, "test-password")
        |> Map.put(:password_confirmation, "test-password")

      conn = put(conn, password_path(conn, :update, user.password_reset_token), user: user_params)
      assert get_flash(conn, :error) == "Password reset token has expired"
      assert redirected_to(conn) == password_path(conn, :new)
    end
  end

  describe "testing admin_reset " do
    setup [:admin_login, :user_with_valid_token]

    test "post /user-password-reset/:user_id with single user id", %{conn: conn, user: user} do
      post(conn, password_path(conn, :admin_reset, user.entry_id))
      updated_user = User.get(user.entry_id)
      refute updated_user.password_reset_token == user.password_reset_token
    end

    test "post /user-password-reset/:user_id for all users", %{conn: conn, user: user} do
      admin = User.get_by(email_hash: "admin@email")
      assert admin.password_reset_token == :nil

      post(conn, password_path(conn, :admin_reset, "all_users"))

      updated_admin = User.get(user.entry_id)
      updated_user = User.get(user.entry_id)

      refute admin.password_reset_token == updated_admin.password_reset_token
      refute updated_admin.password_reset_token == :nil
      refute updated_user.password_reset_token == user.password_reset_token
    end
  end
end