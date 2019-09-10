defmodule CsGuideWeb.StaticPageControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.StaticPage

  import CsGuide.SetupHelpers

  @create_attrs %{
    page_title: "some title",
    title_in_menu: "some title in menu",
    browser_title: "some browser title",
    body: "some body",
    display_in_menu: true,
    display_in_footer: true
  }
  @update_attrs %{
    page_title: "some updated title",
    title_in_menu: "some title in menu",
    browser_title: "some updated browser title",
    body: "some updated body",
    display_in_menu: false,
    display_in_footer: false
  }
  @invalid_attrs %{
    page_title: nil,
    title_in_menu: nil,
    browser_title: nil,
    body: nil,
    display_in_menu: nil,
    display_in_footer: nil
  }

  def fixture(:static_page) do
    {:ok, static_page} =
      %StaticPage{}
      |> StaticPage.changeset(@create_attrs)
      |> StaticPage.insert()

    static_page
  end

  describe "testing meta tags" do
    test "contact meta tag", %{conn: conn} do
      create_static_page("contact")
      conn = get(conn, "/contact")
      assert html_response(conn, 200) =~ "Get in touch with us by email or on social media"
    end

    test "about-us meta tag", %{conn: conn} do
      create_static_page("About-us")
      conn = get(conn, "/about-us")
      assert html_response(conn, 200) =~ "Club Soda is a mindful drinking movement of indiv"
    end

    test "frequently-asked-questions meta tag", %{conn: conn} do
      create_static_page("frequently-asked-questions")
      conn = get(conn, "/frequently-asked-questions")
      assert html_response(conn, 200) =~ "Find out more about the Club Soda Guide, the UK’s"
    end
  end

  describe "index" do
    test "cannot access page if not logged in", %{conn: conn} do
      conn = get(conn, static_page_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:admin_login]

    test "lists all static pages", %{conn: conn} do
      conn = get(conn, static_page_path(conn, :index))
      assert html_response(conn, 200) =~ "All Static Pages"
    end
  end

  describe "new static page" do
    test "does not render form if not logged in", %{conn: conn} do
      conn = get(conn, static_page_path(conn, :new))
      assert html_response(conn, 302)
    end
  end

  describe "new static page - admin" do
    setup [:admin_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, static_page_path(conn, :new))
      assert html_response(conn, 200) =~ "New Static Page"
    end
  end

  describe "create static page" do
    setup [:admin_login]

    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, static_page_path(conn, :create), static_page: @create_attrs)

      assert redirected_to(conn) == static_page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, static_page_path(conn, :create), static_page: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Static Page"
    end
  end

  describe "edit static page" do
    setup [:create_static_page]

    test "non logged in user cannot access form", %{conn: conn, static_page: static_page} do
      conn = get(conn, static_page_path(conn, :edit, static_page.page_title))
      assert html_response(conn, 302)
    end
  end

  describe "static page appears in menu" do
    setup [:create_static_page, :admin_login]

    test "displays static page in menu", %{conn: conn} do
      conn = get(conn, static_page_path(conn, :index))
      assert html_response(conn, 200) =~ "some title in menu"
    end
  end

  describe "edit static page - admin" do
    setup [:create_static_page, :admin_login]

    test "renders form for editing chosen static page", %{conn: conn, static_page: static_page} do
      conn = get(conn, static_page_path(conn, :edit, static_page.page_title))
      assert html_response(conn, 200) =~ "Edit Static Page"
    end
  end

  describe "Title page" do
    test "title of static page is displayed", %{conn: conn} do
      create_static_page("hello")
      conn = get(conn, "/hello")
      assert html_response(conn, 200) =~ "<title>hello</title>"
    end
  end

  describe "update static page" do
    setup [:create_static_page, :admin_login]

    test "redirects when data is valid", %{conn: conn, static_page: static_page} do
      conn =
        put(conn, static_page_path(conn, :update, static_page.page_title),
          static_page: @update_attrs
        )

      page_title = String.replace(@update_attrs.page_title, " ", "-")
      assert redirected_to(conn) == static_page_path(conn, :show, page_title)

      conn = get(conn, static_page_path(conn, :show, @update_attrs.page_title))
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, static_page: static_page} do
      conn =
        put(conn, static_page_path(conn, :update, static_page.page_title),
          static_page: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Static Page"
    end

    test "static page is no longer displayed in menu", %{conn: conn} do
      conn = get(conn, static_page_path(conn, :index))
      assert html_response(conn, 200) != "some title in menu"
    end
  end

  defp create_static_page(arg) when is_map(arg) do
    static_page = fixture(:static_page)
    {:ok, static_page: static_page}
  end

  defp create_static_page(page_name) when is_binary(page_name) do
    params =
      @create_attrs
      |> Map.put(:page_title, page_name)
      |> Map.put(:title_in_menu, page_name)
      |> Map.put(:browser_title, page_name)

    %StaticPage{}
    |> StaticPage.changeset(params)
    |> StaticPage.insert()
  end
end
