defmodule CsGuideWeb.DiscountCodeControllerTest do
  use CsGuideWeb.ConnCase

  import CsGuide.SetupHelpers

  alias CsGuide.DiscountCode

  @create_attrs %{code: "CODE"}
  @update_attrs %{code: "UPDATEDCODE"}
  @invalid_attrs %{code: nil}

  def fixture(:discount_code) do
    {:ok, discount_code} = DiscountCode.insert(@create_attrs)

    discount_code
  end

  describe "index" do
    test "does not list discount codes if not logged in", %{conn: conn} do
      conn = get(conn, discount_code_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all discount codes", %{conn: conn} do
      conn = get(conn, discount_code_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Discount Codes"
    end
  end

  describe "new discount code" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, discount_code_path(conn, :new))
      assert html_response(conn, 200) =~ "New Discount Code"
    end
  end

  describe "create discount code" do
    setup [:admin_login]

    # test "redirects to show when data is valid", %{conn: conn} do
    #   conn = post(conn, discount_code_path(conn, :create), discount_code: @create_attrs)
    #
    #   assert %{id: id} = redirected_params(conn)
    #   assert redirected_to(conn) == discount_code_path(conn, :show, id)
    #
    #   conn = get(conn, discount_code_path(conn, :show, id))
    #   assert html_response(conn, 200) =~ "Show Discount Code"
    # end
  end

  describe "edit discount code" do
    setup [:create_discount_code]

    test "does not render form if not logged in", %{conn: conn, discount_code: discount_code} do
      conn = get(conn, discount_code_path(conn, :edit, discount_code.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit discount code - admin" do
    setup [:create_discount_code, :admin_login]

    test "renders form for editing chosen discount code", %{
      conn: conn,
      discount_code: discount_code
    } do
      conn = get(conn, discount_code_path(conn, :edit, discount_code.entry_id))
      assert html_response(conn, 200) =~ "Edit Discount Code"
    end
  end

  describe "update discount code" do
    setup [:create_discount_code, :admin_login]

    test "redirects when data is valid", %{conn: conn, discount_code: discount_code} do
      conn =
        put(conn, discount_code_path(conn, :update, discount_code.entry_id),
          discount_code: @update_attrs
        )

      assert redirected_to(conn) == discount_code_path(conn, :show, discount_code.entry_id)

      conn = get(conn, discount_code_path(conn, :show, discount_code.entry_id))
      assert html_response(conn, 200) =~ "UPDATEDCODE"
    end

    test "renders errors when data is invalid", %{conn: conn, discount_code: discount_code} do
      conn =
        put(conn, discount_code_path(conn, :update, discount_code.entry_id),
          discount_code: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Discount Code"
    end
  end

  # describe "delete discount_code" do
  #   setup [:create_discount_code]
  #
  #   test "deletes chosen discount_code", %{conn: conn, discount_code: discount_code} do
  #     conn = delete(conn, discount_code_path(conn, :delete, discount_code))
  #     assert redirected_to(conn) == discount_code_path(conn, :index)
  #
  #     assert_error_sent(404, fn ->
  #       get(conn, discount_code_path(conn, :show, discount_code))
  #     end)
  #   end
  # end

  defp create_discount_code(_) do
    discount_code = fixture(:discount_code)
    {:ok, discount_code: discount_code}
  end
end
