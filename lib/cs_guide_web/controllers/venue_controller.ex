defmodule CsGuideWeb.VenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}
  alias CsGuide.Images.VenueImage

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, %{"date_order" => _date_order}) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type ->
          String.downcase(type.name) == "wholesaler" || String.downcase(type.name) == "retailer"
        end)
      end)
      |> sort_venues_by_date

    render(conn, "index.html", venues: venues)
  end

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type ->
          String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
        end)
      end)
      |> Enum.sort_by(& &1.venue_name)

    render(conn, "index.html", venues: venues)
  end

  def new(conn, _params) do
    changeset = Venue.changeset(%Venue{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    slug = Venue.create_slug(venue_params["venue_name"], venue_params["postcode"])
    venue_params = Map.put(venue_params, "slug", slug)
    postcode = venue_params["postcode"]

    changeset =
      %Venue{}
      |> Venue.changeset(venue_params)
      |> Venue.check_existing_slug(slug)
      |> Venue.validate_postcode(postcode)

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue created successfully.")
        |> redirect(to: venue_path(conn, :show, venue.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset =
          CsGuide.ChangesetHelpers.update_error_msg(changeset, Fields.Url, "should be a url")

        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload(
        drinks: [:brand, :drink_types, :drink_styles, :drink_images],
        venue_types: [],
        venue_images: [],
        discount_codes: []
      )

    images = Enum.sort_by(venue.venue_images, fn i -> i.id end)
    venue = Map.put(venue, :venue_images, images)

    nearby_venues = getVenueCardsByLatLong(venue.lat, venue.long, venue.venue_name)
                    |> Enum.take(4)

    if venue != nil do
      venue_owner = conn.assigns[:venue_id] == venue.id

      render(conn, "show.html",
        venue: venue,
        is_authenticated: conn.assigns[:admin] || venue_owner,
        nearby_venues: nearby_venues
      )
    else
      conn
      |> put_view(CsGuideWeb.StaticPageView)
      |> render("404.html")
    end
  end

  def edit(conn, %{"slug" => slug}) do
    venue = Venue.get_by(slug: slug) |> Venue.preload(:venue_types)
    changeset = Venue.changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{
        "slug" => slug,
        "venue" => venue = %{"drinks" => drinks, "num_cocktails" => num_cocktails}
      })
      when map_size(venue) <= 2 do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload([:venue_types, :venue_images, :discount_codes, :drinks, :users])

    venue_params =
      venue
      |> Map.from_struct()
      |> Map.drop([:users])
      |> Map.put(:drinks, drinks)
      |> Map.put(:num_cocktails, num_cocktails)

    do_update(conn, venue, venue_params)
  end

  def update(conn, %{"slug" => slug, "venue" => venue_params}) do
    v_name = venue_params["venue_name"]
    v_postcode = venue_params["postcode"]
    new_slug = Venue.create_slug(v_name, v_postcode)

    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload([:venue_types, :venue_images, :discount_codes, :drinks, :users])

    venue_params =
      venue_params
      |> Map.put("slug", new_slug)
      |> Map.put("drinks", venue.drinks)

    case Venue.update(venue, venue_params, v_postcode) do
      {:ok, _venue} ->
        conn
        |> put_flash(:info, "Venue updated successfully.")
        |> redirect(to: venue_path(conn, :show, Map.get(venue_params, "slug", slug)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end

  defp do_update(conn, venue, venue_params) do
    query = fn s, m ->
      sub =
        from(mod in Map.get(m.__schema__(:association, s), :queryable),
          distinct: mod.entry_id,
          order_by: [desc: :inserted_at],
          select: mod
        )

      from(m in subquery(sub), where: not m.deleted, select: m)
    end

    with {:ok, venue} <- Venue.update(venue, venue_params),
         {:ok, venue} <-
           Venue.update(
             venue,
             Map.put(
               venue_params,
               :cs_score,
               CsGuide.Resources.CsScore.calculateScore(
                 venue.drinks
                 |> CsGuide.Repo.preload(drink_types: query.(:drink_types, Drink)),
                 venue.num_cocktails
               )
             )
           ) do
      conn
      |> put_flash(:info, "Venue updated successfully.")
      |> redirect(to: venue_path(conn, :show, venue.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end

  def add_drinks(conn, %{"slug" => slug}) do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload(drinks: [:brand], venue_types: [])

    brands = Brand.all() |> Brand.preload(:drinks)

    changeset = Venue.changeset(venue)

    render(conn, "add_drinks.html",
      brands: brands,
      current_drinks: Enum.map(venue.drinks, fn d -> d.entry_id end),
      changeset: changeset,
      action: venue_path(conn, :update, slug)
    )
  end

  def add_photo(conn, %{"slug" => slug}) do
    venue = Venue.get_by(slug: slug)
    render(conn, "add_photo.html", id: venue.entry_id)
  end

  def upload_photo(conn, params) do
    venue = Venue.get(params["id"])

    CsGuide.Repo.transaction(fn ->
      with {:ok, venue_image} <- VenueImage.insert(%{venue: params["id"]}),
           {:ok, _} <- CsGuide.Resources.upload_photo(params, venue_image.entry_id) do
        {:ok, venue_image}
      else
        val ->
          CsGuide.Repo.rollback(val)
      end
    end)
    |> case do
      {:ok, _} -> redirect(conn, to: venue_path(conn, :show, venue.slug))
      {:error, _} -> render(conn, "add_photo.html", id: venue.entry_id, error: true)
    end
  end

  defp compareDates(date1, date2) do
    case NaiveDateTime.compare(date1, date2) do
      :gt ->
        true

      _ ->
        false
    end
  end

  def sort_venues_by_date(venues) do
    Enum.sort(venues, &compareDates(&1.inserted_at, &2.inserted_at))
  end

  def delete(conn, %{"id" => id}) do
    venue = Venue.get(id)
    {:ok, _v} = Venue.delete(venue)

    conn
    |> put_flash(:info, "Venue deleted successfully.")
    |> redirect(to: venue_path(conn, :index))
  end

  defp getVenueCardsByLatLong(lat, long, venue_name) do
    Venue.nearest_venues(lat, long)
    |> Venue.preload([:venue_types, :venue_images])
    |> Enum.filter(fn v ->
      !Enum.find(v.venue_types, fn type ->
        String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
      end)
    end)
    |> Enum.filter(fn v ->
      v.venue_name != venue_name
    end)
  end
end
