defmodule CsGuideWeb.BrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Brand, Venue, Drink}
  alias CsGuide.Images.BrandImage
  alias CsGuide.DiscountCode
  import Ecto.Query

  def index(conn, _params) do
    brands = Brand.all()
    IO.inspect Enum.filter(brands, &(&1.slug == nil))
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
        changeset =
          CsGuide.ChangesetHelpers.update_error_msg(changeset, Fields.Url, "should be a url")

        render(conn, "new.html", changeset: changeset)
    end
  end

  defp make_query(retailer_id) do
    from(dc in DiscountCode,
      limit: 1,
      select: dc,
      where: dc.venue_id == ^retailer_id,
      order_by: [desc: dc.updated_at]
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

  def show(conn, %{"slug" => slug}) do
    dd_code = get_code("DryDrinker")
    wb_code = get_code("WiseBartender")

    brand =
      Brand.get_by([slug: slug])
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
      brand =
        Map.update(brand, :brand_images, [], fn images ->
          images
          |> Enum.sort(fn img1, img2 ->
            img1.id >= img2.id
          end)
        end)

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

  def edit(conn, %{"slug" => slug}) do
    brand = Brand.get_by([slug: slug])
    changeset = Brand.changeset(brand, %{})
    render(conn, "edit.html", brand: brand, changeset: changeset)
  end

  def update(conn, %{"slug" => slug, "brand" => brand_params}) do
    brand = Brand.get_by([slug: slug])

    case brand |> Brand.changeset(brand_params) |> Brand.update() do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :show, brand.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brand: brand, changeset: changeset)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    brand = Brand.get_by([slug: slug])
    {:ok, _brand} = Brand.delete(brand)

    conn
    |> put_flash(:info, "Brand deleted successfully.")
    |> redirect(to: brand_path(conn, :index))
  end

  def add_photo(conn, %{"slug" => slug}) do
    case Brand.get_by([slug: slug]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(CsGuideWeb.ErrorView)
        |> render("404.html")

      _brand ->
        render(conn, "add_photo.html", slug: slug)
    end
  end

  def add_cover_photo(conn, %{"slug" => slug}) do
    case Brand.get_by([slug: slug]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(CsGuideWeb.ErrorView)
        |> render("404.html")

      _brand ->
        render(conn, "add_cover_photo.html", slug: slug)
    end
  end

  def upload_photo(conn, params) do
    one = if params["cover_photo"], do: true, else: false

    brand = Brand.get_by([slug: params["slug"]])

    CsGuide.Repo.transaction(fn ->
      with {:ok, brand_image} <-
             BrandImage.insert(%{
               brand: brand.entry_id,
               one: one
             }),
           {:ok, _} <- CsGuide.Resources.upload_photo(params, brand_image.entry_id) do
        {:ok, brand_image}
      else
        val ->
          CsGuide.Repo.rollback(val)
      end
    end)
    |> case do
      {:ok, _} -> redirect(conn, to: brand_path(conn, :show, params["slug"]))
      {:error, _} -> render(conn, "add_photo.html", id: params["id"], error: true)
    end
  end

  defp check_brand_name(name) do
      name
      |> String.split("-") |> Enum.join(" ")
      |> String.split("_") |> Enum.join("-")
  end
end
