defmodule CsGuideWeb.VenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}
  alias CsGuide.Images.VenueImage

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, %{"date_order" => date_order}) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end)
      end)
      |> sort_venues_by_date

    render(conn, "index.html", venues: venues)
  end

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end)
      end)
      |> Enum.sort_by(& &1.venue_name)

    render(conn, "index.html", venues: venues)
  end

  def new(conn, _params) do
    changeset = Venue.changeset(%Venue{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    case Venue.insert(venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue created successfully.")
        |> redirect(to: venue_path(conn, :show, CsGuideWeb.VenueView.generate_venue_url(venue)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def get_name(unique_name) do
    String.replace(unique_name, "-", " ")
    |> String.replace(~r/((\s){3})/, " - ")
    |> String.split(" ")
    |> Enum.split(-2)
    |> Tuple.to_list()
    |> Enum.at(0)
    |> Enum.join(" ")
  end

  def get_postcode(unique_name) do
    String.replace(unique_name, "-", " ")
    |> String.split(" ")
    |> Enum.split(-2)
    |> Tuple.to_list()
    |> Enum.at(1)
    |> Enum.join(" ")
  end

  def show(conn, %{"unique_name" => unique_name}) do
    name = get_name(unique_name)
    postcode = get_postcode(unique_name)

    venue =
      Venue.get_by([venue_name: name, postcode: postcode], case_insensitive: true)
      |> Venue.preload(
        drinks: [:brand, :drink_types, :drink_styles, :drink_images],
        venue_types: [],
        venue_images: []
      )

    venue_owner = conn.assigns[:venue_id] == venue.id
    render(conn, "show.html", venue: venue, is_authenticated: conn.assigns[:admin] || venue_owner)
  end

  def edit(conn, %{"unique_name" => unique_name}) do
    name = get_name(unique_name)
    postcode = get_postcode(unique_name)

    venue =
      Venue.get_by([venue_name: name, postcode: postcode], case_insensitive: true)
      |> Venue.preload(:venue_types)

    changeset = Venue.changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{
        "unique_name" => unique_name,
        "venue" => venue = %{"drinks" => drinks, "num_cocktails" => num_cocktails}
      })
      when map_size(venue) <= 2 do
    name = get_name(unique_name)
    postcode = get_postcode(unique_name)

    venue =
      Venue.get_by([venue_name: name, postcode: postcode], case_insensitive: true)
      |> Venue.preload([:venue_types, :venue_images, :drinks, :users])

    venue_params =
      venue
      |> Map.from_struct()
      |> Map.drop([:users])
      |> Map.put(:drinks, drinks)
      |> Map.put(:num_cocktails, num_cocktails)

    do_update(conn, venue, venue_params)
  end

  def update(conn, %{"unique_name" => id, "venue" => venue_params}) do
    venue = Venue.get(id) |> Venue.preload([:venue_types, :venue_images, :drinks, :users])

    case Venue.update(venue, venue_params |> Map.put("drinks", venue.drinks)) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue updated successfully.")
        |> redirect(to: venue_path(conn, :show, CsGuideWeb.VenueView.generate_venue_url(venue)))

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
      |> redirect(to: venue_path(conn, :show, CsGuideWeb.VenueView.generate_venue_url(venue)))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end

  def add_drinks(conn, %{"unique_name" => unique_name}) do
    name = get_name(unique_name)
    postcode = get_postcode(unique_name)

    venue =
      Venue.get_by([venue_name: name, postcode: postcode], case_insensitive: true)
      |> Venue.preload(drinks: [:brand], venue_types: [])

    brands = Brand.all() |> Brand.preload(:drinks)

    changeset = Venue.changeset(venue)

    render(conn, "add_drinks.html",
      brands: brands,
      current_drinks: Enum.map(venue.drinks, fn d -> d.entry_id end),
      changeset: changeset,
      action: venue_path(conn, :update, CsGuideWeb.VenueView.generate_venue_url(venue))
    )
  end

  def add_photo(conn, %{"unique_name" => unique_name}) do
    render(conn, "add_photo.html", unique_name: unique_name)
  end

  def upload_photo(conn, params) do
    name = get_name(params["unique_name"])
    postcode = get_postcode(params["unique_name"])
    venue = Venue.get_by(venue_name: name, postcode: postcode)

    CsGuide.Repo.transaction(fn ->
      with {:ok, venue_image} <- VenueImage.insert(%{venue: venue.entry_id}),
           {:ok, _} <- CsGuide.Resources.upload_photo(params, venue_image.entry_id) do
        {:ok, venue_image}
      else
        val ->
          CsGuide.Repo.rollback(val)
      end
    end)
    |> case do
      {:ok, _} ->
        redirect(conn, to: venue_path(conn, :show, CsGuideWeb.VenueView.generate_venue_url(venue)))

      {:error, _} ->
        render(conn, "add_photo.html", unique_name: params["unique_name"], error: true)
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
end
