defmodule CsGuideWeb.UserControllerTest do
  use CsGuideWeb.ConnCase

  import CsGuide.SetupHelpers

  alias CsGuide.Accounts.User

  @create_attrs %{email: "some@email"}
  @update_attrs %{email: "some@updated.email"}
  @invalid_attrs %{email: nil}

  def fixture(:user) do
    {:ok, user} = %User{} |> User.changeset(@create_attrs) |> User.insert()
    user
  end

  describe "index" do
    test "does not list users if not logged in", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all users", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "Create a Venue Listing"
    end
  end

  describe "create user" do
    setup [:admin_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == user_path(conn, :show, id)

      conn = get(conn, user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "does not render form if not logged in", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :edit, user.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit user - admin" do
    setup [:create_user, :admin_login]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :edit, user.entry_id))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user, :admin_login]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user.entry_id), user: @update_attrs)
      assert redirected_to(conn) == user_path(conn, :show, user.entry_id)

      conn = get(conn, user_path(conn, :show, user.entry_id))
      assert html_response(conn, 200) =~ "some@updated.email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user.entry_id), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "create site admin" do
    setup [:create_user, :admin_login]

    test "get admin/users/new-site-admin", %{conn: conn} do
      conn = get(conn, user_path(conn, :new_site_admin))
      assert html_response(conn, 200) =~ "Create new site admin"
    end

    test "post admin/users/create-site-admin", %{conn: conn} do
      conn = post(conn, user_path(conn, :create_site_admin, %{"user" => %{"email" => "newadmin@email"}}))

      new_admin = User.get_by(email_hash: "newadmin@email")
      refute new_admin == nil
      assert new_admin.role == :site_admin
      assert redirected_to(conn) == admin_path(conn, :index)
      assert get_flash(conn, :info) =~ "Site admin created successfully"
    end

    test "post admin/users/create-site-admin with invalid email", %{conn: conn} do
      conn = post(conn, user_path(conn, :create_site_admin, %{"user" => %{"email" => "invalid"}}))

      assert html_response(conn, 200) =~ "Create new site admin"
      assert html_response(conn, 200) =~ "is invalid"
    end

    test "post admin/users/create-site-admin with email that is already used", %{conn: conn} do
      conn = post(conn, user_path(conn, :create_site_admin, %{"user" => %{"email" => "some@email"}}))

      assert html_response(conn, 200) =~ "Create new site admin"
      assert html_response(conn, 200) =~ "has already been taken"
    end
  end

  # describe "delete user" do
  #   setup [:create_user]
  #
  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, user_path(conn, :delete, user))
  #     assert redirected_to(conn) == user_path(conn, :index)
  #
  #     assert_error_sent(404, fn ->
  #       get(conn, user_path(conn, :show, user))
  #     end)
  #   end
  # end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
