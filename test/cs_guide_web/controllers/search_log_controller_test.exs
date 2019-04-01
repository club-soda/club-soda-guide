defmodule CsGuideWeb.SearchLogControllerTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Repo, SearchLog}

  import CsGuide.SetupHelpers

  @create_attrs %{
    search: "London",
  }

  def fixture(:search_log) do
    {:ok, searchlog } = SearchLog.changeset(%SearchLog{}, @create_attrs) |> Repo.insert()
    searchlog
  end

  describe "index" do
    test "cannot access page if not logged in", %{conn: conn} do
      conn = get(conn, search_log_path(conn, :index))
      assert html_response(conn, 302)
    end
  end

  describe "index - admin" do
    setup [:create_log, :admin_login]

    test "lists all sponsors", %{conn: conn} do
      conn = get(conn, search_log_path(conn, :index))
      assert html_response(conn, 200) =~ "All Searches log"
      assert html_response(conn, 200) =~ "London"
    end
  end

  defp create_log(_) do
    search_log = fixture(:search_log)
    {:ok, search_log: search_log}
  end

end
