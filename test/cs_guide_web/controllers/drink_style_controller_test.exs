defmodule CsGuideWeb.DrinkStyleControllerTest do
  use CsGuideWeb.ConnCase

  import CsGuide.SetupHelpers

  alias CsGuide.Categories.DrinkStyle

  @create_attrs %{deleted: false, name: "some name"}
  @update_attrs %{deleted: false, name: "some updated name"}
  @invalid_attrs %{deleted: nil, entry_id: nil, name: nil}

  def fixture(:drink_style) do
    {:ok, drink_style} =
      %DrinkStyle{} |> DrinkStyle.changeset(@create_attrs) |> DrinkStyle.insert()

    drink_style
  end

  describe "index" do
    test "does not render if not logged in", %{conn: conn} do
      conn = get(conn, drink_style_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all drink_styles", %{conn: conn} do
      conn = get(conn, drink_style_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Drink Styles"
    end
  end

  describe "new drink_style" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, drink_style_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new drink_style - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, drink_style_path(conn, :new))
      assert html_response(conn, 200) =~ "New Drink style"
    end
  end

  describe "create drink_style" do
    setup [:admin_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, drink_style_path(conn, :create), drink_style: @create_attrs)

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) == drink_style_path(conn, :show, id)

      conn = get(conn, drink_style_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Drink style"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, drink_style_path(conn, :create), drink_style: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Drink style"
    end
  end

  describe "edit drink_style" do
    setup [:create_drink_style]

    test "does not render form if not logged in", %{conn: conn, drink_style: drink_style} do
      conn = get(conn, drink_style_path(conn, :edit, drink_style.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit drink_style - admin" do
    setup [:create_drink_style, :admin_login]

    test "renders form for editing chosen drink_style", %{conn: conn, drink_style: drink_style} do
      conn = get(conn, drink_style_path(conn, :edit, drink_style.entry_id))
      assert html_response(conn, 200) =~ "Edit Drink style"
    end
  end

  describe "update drink_style" do
    setup [:create_drink_style, :admin_login]

    test "redirects when data is valid", %{conn: conn, drink_style: drink_style} do
      conn =
        put(conn, drink_style_path(conn, :update, drink_style.entry_id),
          drink_style: @update_attrs
        )

      assert redirected_to(conn) == drink_style_path(conn, :show, drink_style.entry_id)

      conn = get(conn, drink_style_path(conn, :show, drink_style.entry_id))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, drink_style: drink_style} do
      conn =
        put(conn, drink_style_path(conn, :update, drink_style.entry_id),
          drink_style: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Drink style"
    end
  end

  # describe "delete drink_style" do
  #   setup [:create_drink_style]
  #
  #   test "deletes chosen drink_style", %{conn: conn, drink_style: drink_style} do
  #     conn = delete(conn, drink_style_path(conn, :delete, drink_style))
  #     assert redirected_to(conn) == drink_style_path(conn, :index)
  #
  #     assert_error_sent(404, fn ->
  #       get(conn, drink_style_path(conn, :show, drink_style))
  #     end)
  #   end
  # end

  defp create_drink_style(_) do
    drink_style = fixture(:drink_style)
    {:ok, drink_style: drink_style}
  end
end
