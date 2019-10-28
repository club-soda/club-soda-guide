defmodule CsGuideWeb.BrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Brand, Venue, Drink}
  alias CsGuide.Images.BrandImage
  alias CsGuide.DiscountCode
  alias CsGuideWeb.{VenueController, SearchVenueController}
  import Ecto.Query

  def index(conn, _params) do
    brands =
      Brand.all()
      |> Enum.sort_by(&String.first(&1.name))

    render(conn, "index.html", brands: brands)
  end

  def new(conn, _params) do
    changeset = Brand.changeset(%Brand{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"brand" => brand_params}) do
    changeset =
      %Brand{}
      |> Brand.changeset(brand_params)
      |> CsGuide.ChangesetHelpers.check_existing_slug(Brand, :name, "Brand already exists")

    case Brand.insert(changeset) do
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

  defp calc_distance({lat1, long1}, {lat2, long2}) do
    # Radian
    v = :math.pi() / 180
    # km for the earth radius
    r = 6372.8

    dlat = :math.sin((lat2 - lat1) * v / 2)
    dlong = :math.sin((long2 - long1) * v / 2)
    a = dlat * dlat + dlong * dlong * :math.cos(lat1 * v) * :math.cos(lat2 * v)
    r * 2 * :math.asin(:math.sqrt(a))
  end

  defp get_venues(brand) do
    brand.drinks
    |> Enum.map(fn d ->
      d.venues
    end)
    |> List.flatten()
    |> Enum.filter(fn v ->
      String.downcase(v.venue_name) != "drydrinker" &&
        String.downcase(v.venue_name) != "wisebartender"
    end)
    |> Enum.uniq()
    |> sort_by_cs_score()
    |> Enum.filter(fn v ->
      !Enum.any?(v.venue_types, fn t ->
        String.downcase(t.name) == "retailer" || String.downcase(t.name) == "wholesaler"
      end)
    end)
  end

  defp sort_by_cs_score(venues) do
    venues
    |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
    |> Enum.chunk_by(fn v ->
      v.cs_score
    end)
    |> Enum.map(fn list -> Enum.shuffle(list) end)
    |> List.flatten()
  end

  defp get_brand_info(brand) do
    brand
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
    |> Map.update(:venues, [], fn venues ->
      venues
      |> Enum.map(&VenueController.sort_images_by_most_recent/1)
    end)
    |> Map.update(:venues, [], fn venues ->
      venues
      |> Enum.map(&SearchVenueController.selectPhotoNumber1/1)
    end)
    |> Map.update(:drinks, [], fn drinks ->
      Enum.map(drinks, fn drink ->
        %{drink | drink_images: Enum.sort_by(drink.drink_images, &(&1.id), &>=/2) }
      end)
    end)
  end

  defp get_related_drinks(_brand, nil), do: []

  defp get_related_drinks(brand, drink_style) do
    Drink.all()
    |> Drink.preload([
      :drink_images,
      :brand,
      :drink_types,
      :drink_styles,
      venues: [:venue_types, :venue_images]
    ])
    |> Enum.filter(fn d ->
      Enum.any?(d.drink_styles, fn t ->
        t.name == drink_style
      end)
    end)
    |> Enum.reject(fn d -> d.brand.name == brand.name end)
    |> Enum.sort_by(&(&1.weighting || 0), &>=/2)
    |> Enum.take(4)
  end

  defp get_sorted_venues(ll, brand) do
    if ll != "" do
      [user_lat, user_long] =
        ll
        |> String.split(",")
        |> Enum.map(&String.to_float/1)

      brand
      |> get_venues()
      |> Enum.filter(fn v -> v.lat != nil || v.long != nil end)
      |> Enum.sort(fn v1, v2 ->
        if v1.lat != nil || v1.long != nil || v2.lat != nil || v2.long != nil do
          calc_distance({v1.lat, v1.long}, {user_lat, user_long}) <=
            calc_distance({v2.lat, v2.long}, {user_lat, user_long})
        else
          get_venues(brand)
        end
      end)
    else
      get_venues(brand)
    end
  end

  def show_helper(params, ll \\ "") do
    %{"slug" => slug} = params
    basic_brand_info = Brand.get_by(slug: slug)

    if basic_brand_info != nil do
      brand = get_brand_info(basic_brand_info)
      brand_style = Drink.get_drink_style(brand.drinks)
      IO.inspect(brand.drinks)
      # Will assign brands with no drink_type background colour of spirits banner
      drink_type = Drink.get_drink_type(brand.drinks) || "Spirits"

      %{
        brand: brand,
        related_drinks: get_related_drinks(brand, brand_style),
        dd_code: get_code("DryDrinker"),
        wb_code: get_code("WiseBartender"),
        drink_type: drink_type,
        venues: get_sorted_venues(ll, brand)
      }
    else
      nil
    end
  end

  defp render_brands(conn, assigns) do
    if assigns != nil do
      brand =
        Map.update(assigns.brand, :brand_images, [], fn images ->
          images
          |> Enum.sort(fn img1, img2 ->
            img1.id >= img2.id
          end)
        end)

      is_authenticated =
        if not is_nil(conn.assigns.current_user) do
          conn.assigns.current_user.role == :site_admin
        else
          false
        end

      render(conn, "show.html",
        brand: brand,
        related_drinks: assigns.related_drinks,
        is_authenticated: is_authenticated,
        dd_discount_code: assigns.dd_code,
        wb_discount_code: assigns.wb_code,
        drink_type: assigns.drink_type,
        venues: assigns.venues
      )
    else
      conn
      |> put_view(CsGuideWeb.StaticPageView)
      |> render("404.html")
    end
  end

  def show(conn, %{"ll" => latlong} = params) do
    assigns = show_helper(params, latlong)
    render_brands(conn, assigns)
  end

  def show(conn, params) do
    assigns = show_helper(params)
    render_brands(conn, assigns)
  end

  def edit(conn, %{"slug" => slug}) do
    brand = Brand.get_by(slug: slug)
    changeset = Brand.changeset(brand, %{})
    render(conn, "edit.html", brand: brand, changeset: changeset)
  end

  def update(conn, %{"slug" => slug, "brand" => brand_params}) do
    brand = Brand.get_by(slug: slug)

    case brand |> Brand.changeset(brand_params) |> Brand.update() do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :show, brand.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brand: brand, changeset: changeset)
    end
  end

  def delete(conn, %{"entry_id" => entry_id}) do
    brand = Brand.get_by(entry_id: entry_id)
    {:ok, _brand} = Brand.delete(brand)

    conn
    |> put_flash(:info, "Brand deleted successfully.")
    |> redirect(to: brand_path(conn, :index))
  end

  def add_photo(conn, %{"slug" => slug}) do
    case Brand.get_by(slug: slug) do
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
    case Brand.get_by(slug: slug) do
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

    brand = Brand.get_by(slug: params["slug"])

    CsGuide.Repo.transaction(fn ->
      with {:ok, brand_image} <-
             BrandImage.insert(%{
               brand: brand.entry_id,
               one: one,
               extension: CsGuide.Resources.get_file_extension(params)
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
end
