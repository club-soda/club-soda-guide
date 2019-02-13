defmodule CsGuideWeb.SponsorControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Sponsor

  import CsGuide.SetupHelpers

  @create_attrs %{
    name: "some name",
    body: "some body",
    show: true
  }
  @update_attrs %{
    name: "some name",
    body: "some body",
    show: false
  }
  @invalid_attrs %{
    name: nil,
    body: nil,
    show: nil
  }

  def fixture(:sponsor) do
    {:ok, sponsor} = Sponsor.insert(@create_attrs)

    sponsor
  end

  describe "index" do
    test "cannot access page if not logged in", %{conn: conn} do
      conn = get(conn, sponsor_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all sponsors", %{conn: conn} do
      conn = get(conn, sponsor_path(conn, :index))
      assert html_response(conn, 200) =~ "All Sponsors"
    end
  end

  describe "new sponsor" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, sponsor_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new sponsor - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, sponsor_path(conn, :new))
      assert html_response(conn, 200) =~ "New Sponsor"
    end
  end

  describe "create static page" do
    setup [:admin_login]

    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, sponsor_path(conn, :create), sponsor: @create_attrs)

      assert redirected_to(conn) == sponsor_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, sponsor_path(conn, :create), sponsor: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Sponsor"
    end
  end

  describe "edit sponsor" do
    setup [:create_sponsor]

    test "non logged in user cannot access form", %{conn: conn, sponsor: sponsor} do
      conn = get(conn, sponsor_path(conn, :edit, sponsor.entry_id))
      assert html_response(conn, 302)
    end
  end

  describe "edit sponsor - admin" do
    setup [:create_sponsor, :admin_login]

    test "renders form for editing chosen sponsor", %{conn: conn, sponsor: sponsor} do
      conn = get(conn, sponsor_path(conn, :edit, sponsor.entry_id))
      assert html_response(conn, 200) =~ "Edit Sponsor"
    end
  end

  describe "update sponsor" do
    setup [:create_sponsor, :admin_login]

    test "redirects when data is valid", %{conn: conn, sponsor: sponsor} do
      conn = get(conn, page_path(conn, :index))
      assert html_response(conn, 200) =~ "some body"

      conn = put(conn, sponsor_path(conn, :update, sponsor.entry_id), sponsor: @update_attrs)
      assert redirected_to(conn) == sponsor_path(conn, :index)

      conn = get(conn, page_path(conn, :index))
      refute html_response(conn, 200) =~ "some body"
    end

    test "renders errors when data is invalid", %{conn: conn, sponsor: sponsor} do
      conn = put(conn, sponsor_path(conn, :update, sponsor.entry_id), sponsor: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Sponsor"
    end
  end

  defp create_sponsor(_) do
    sponsor = fixture(:sponsor)
    {:ok, sponsor: sponsor}
  end
end
