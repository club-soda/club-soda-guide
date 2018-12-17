defmodule CsGuideWeb.BrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Brand
  alias CsGuide.Images.BrandImage

  def index(conn, _params) do
    brands = Brand.all()
    render(conn, "index.html", brands: brands)
  end

  def new(conn, _params) do
    changeset = Brand.changeset(%Brand{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"brand" => brand_params}) do
    case %Brand{} |> Brand.changeset(brand_params) |> Brand.insert() do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand created successfully.")
        |> redirect(to: brand_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"name" => name}) do
    brand =
      Brand.get_by([name: name], case_insensitive: true)
      |> Brand.preload(
        drinks: [
          :drink_images,
          :brand,
          :drink_types,
          :drink_styles,
          venues: [:venue_types, :venue_images]
        ],
        brand_images: []
      )

    render(conn, "show.html", brand: brand, is_authenticated: conn.assigns[:admin])
  end

  def edit(conn, %{"name" => name}) do
    brand = Brand.get_by([name: name], case_insensitive: true)
    changeset = Brand.changeset(brand, %{})
    render(conn, "edit.html", brand: brand, changeset: changeset)
  end

  def update(conn, %{"name" => name, "brand" => brand_params}) do
    brand = Brand.get_by([name: name], case_insensitive: true)

    case brand |> Brand.changeset(brand_params) |> Brand.update() do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :show, brand.name))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brand: brand, changeset: changeset)
    end
  end

  def delete(conn, %{"name" => name}) do
    brand = Brand.get_by([name: name], case_insensitive: true)
    {:ok, _brand} = Brand.delete(brand)

    conn
    |> put_flash(:info, "Brand deleted successfully.")
    |> redirect(to: brand_path(conn, :index))
  end

  def add_photo(conn, %{"name" => name}) do
    case Brand.get_by([name: name], case_insensitive: true) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(CsGuideWeb.ErrorView)
        |> render("404.html")

      brand ->
        render(conn, "add_photo.html", name: name)
    end
  end

  def upload_photo(conn, params) do
    CsGuide.Repo.transaction(fn ->
      with {:ok, brand_image} <-
             BrandImage.insert(%{
               brand: params["id"],
               cover: String.to_existing_atom(params["cover"])
             }),
           {:ok, _} <- CsGuide.Resources.upload_photo(params, brand_image.entry_id) do
        {:ok, brand_image}
      else
        val ->
          CsGuide.Repo.rollback(val)
      end
    end)
    |> case do
      {:ok, _} -> redirect(conn, to: brand_path(conn, :show, params["id"]))
      {:error, _} -> render(conn, "add_photo.html", id: params["id"], error: true)
    end
  end
end
