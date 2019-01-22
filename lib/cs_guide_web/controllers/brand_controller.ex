defmodule CsGuideWeb.BrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Brand, Venue, Drink}
  alias CsGuide.Images.BrandImage
  alias CsGuide.DiscountCode
  import Ecto.Query

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
      {:ok, _brand} ->
        conn
        |> put_flash(:info, "Brand created successfully.")
        |> redirect(to: brand_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp make_query(retailer_id) do
    from(dc in DiscountCode,
      limit: 1,
      select: dc,
      where: dc.venue_id == ^retailer_id,
      order_by: [desc: dc.inserted_at]
    )
  end

  defp get_code(retailer_name) do
    case Venue.get_by(venue_name: retailer_name) do
      nil ->
        nil

      retailer ->
        retailer.id
        |> make_query()
        |> CsGuide.Repo.one()
        |> case do
          nil ->
            nil

          discount_code ->
            discount_code.code
        end
    end
  end

  def show(conn, %{"name" => name}) do
    dd_code = get_code("DryDrinker")
    wb_code = get_code("WiseBartender")

    name = check_brand_name(name)

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

    {drink_type, count} =
      Enum.map(brand.drinks, fn d ->
        Enum.map(d.drink_types, fn t -> t.name end)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, fn drink_type, acc ->
        Map.update(acc, drink_type, 1, fn value -> value + 1 end)
      end)
      # Will assign brands with no drink_type background colour of spirits banner
      |> Enum.reduce({"Spirits", 0}, fn {drink_type, count}, acc ->
        case acc do
          {} ->
            {drink_type, count}

          {acc_dtype, acc_count} ->
            if count > acc_count do
              {drink_type, count}
            else
              {acc_dtype, acc_count}
            end
        end
      end)

    related_drinks =
      Drink.all()
      |> Drink.preload([
        :drink_images,
        :brand,
        :drink_types,
        :drink_styles,
        venues: [:venue_types, :venue_images]
      ])
      |> Enum.filter(fn d ->
        Enum.any?(d.drink_types, fn t ->
          t.name == drink_type
        end)
      end)
      |> Enum.reject(fn d -> d.brand.name == brand.name end)
      |> Enum.take(4)

    if brand != nil do
      render(conn, "show.html",
        brand: brand,
        related_drinks: related_drinks,
        is_authenticated: conn.assigns[:admin],
        dd_discount_code: dd_code,
        wb_discount_code: wb_code,
        drink_type: drink_type
      )
    else
      conn
      |> put_view(CsGuideWeb.StaticPageView)
      |> render("404.html")
    end
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

      _brand ->
        render(conn, "add_photo.html", name: name)
    end
  end

  def upload_photo(conn, params) do
    brand = Brand.get_by([name: params["name"]], case_insensitive: true)

    CsGuide.Repo.transaction(fn ->
      with {:ok, brand_image} <-
             BrandImage.insert(%{
               brand: brand.entry_id,
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
      {:ok, _} -> redirect(conn, to: brand_path(conn, :show, params["name"]))
      {:error, _} -> render(conn, "add_photo.html", id: params["id"], error: true)
    end
  end

  defp check_brand_name(name) do
    brands_with_hyphens = ~w(Fritz-Kola)

    if Enum.any?(brands_with_hyphens, &(&1 == name)) do
      name
    else
      name |> String.split("-") |> Enum.join(" ")
    end
  end
end
