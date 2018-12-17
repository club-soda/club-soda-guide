defmodule CsGuideWeb.StaticPageController do
  use CsGuideWeb, :controller

  alias CsGuide.StaticPage

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, _params) do
    static_pages = StaticPage.all()

    render(conn, "index.html", static_pages: static_pages)
  end

  def new(conn, _params) do
    changeset = StaticPage.changeset(%StaticPage{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"static_page" => static_page_params}) do
    case %StaticPage{} |> StaticPage.changeset(static_page_params) |> StaticPage.insert() do
      {:ok, static_page} ->
        conn
        |> put_flash(:info, "Static Page created successfully.")
        |> redirect(to: static_page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"page_title" => page_title}) do
    static_page = StaticPage.get_by([page_title: page_title], case_insensitive: true)

    render(conn, "show.html", static_page: static_page)
  end

  def edit(conn, %{"page_title" => page_title}) do
    static_page = StaticPage.get_by([page_title: page_title], case_insensitive: true)

    changeset = StaticPage.changeset(static_page)
    render(conn, "edit.html", static_page: static_page, changeset: changeset)
  end

  def update(conn, %{"page_title" => page_title, "static_page" => static_page_params}) do
    static_page = StaticPage.get_by([page_title: page_title], case_insensitive: true)

    case static_page |> StaticPage.changeset(static_page_params) |> StaticPage.update() do
      {:ok, static_page} ->
        conn
        |> put_flash(:info, "Static Page updated successfully.")
        |> redirect(to: static_page_path(conn, :show, static_page.page_title))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", static_page: static_page, changeset: changeset)
    end
  end

  defp do_update(conn, static_page, static_page_params) do
    query = fn s, m ->
      sub =
        from(mod in Map.get(m.__schema__(:association, s), :queryable),
          distinct: mod.entry_id,
          order_by: [desc: :inserted_at],
          select: mod
        )

      from(m in subquery(sub), where: not m.deleted, select: m)
    end

    with {:ok, static_page} <- static_page.update(static_page, static_page_params),
         {:ok, static_page} <- StaticPage.update(static_page) do
      conn
      |> put_flash(:info, "Static Page updated successfully.")
      |> redirect(to: static_page_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", static_page: static_page, changeset: changeset)
    end
  end
end
