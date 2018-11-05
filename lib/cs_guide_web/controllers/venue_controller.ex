defmodule CsGuideWeb.VenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, _params) do
    venues = Venue.all()
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
        |> redirect(to: venue_path(conn, :show, venue.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    venue =
      id
      |> Venue.get()
      |> Venue.preload(drinks: [:brand, :drink_types], venue_types: [])

    render(conn, "show.html", venue: venue)
  end

  def edit(conn, %{"id" => id}) do
    venue = Venue.get(id)
    changeset = Venue.changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{"id" => id, "venue" => venue = %{"drinks" => drinks}})
      when map_size(venue) == 1 do
    venue = Venue.get(id)
    venue_params = Map.put(Map.from_struct(venue), :drinks, drinks)

    do_update(conn, venue, venue_params)
  end

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    venue = Venue.get(id)

    do_update(conn, venue, venue_params)
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
                 |> CsGuide.Repo.preload(drink_types: query.(:drink_types, Drink))
               )
             )
           ) do
      conn
      |> put_flash(:info, "Venue updated successfully.")
      |> redirect(to: venue_path(conn, :show, venue.entry_id))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    # venue = Resources.get_venue!(id)
    # {:ok, _venue} = Resources.delete_venue(venue)

    # conn
    # |> put_flash(:info, "Venue deleted successfully.")
    # |> redirect(to: venue_path(conn, :index))
  end

  def add_drinks(conn, %{"id" => id}) do
    venue =
      id
      |> Venue.get()
      |> Venue.preload(drinks: [:brand])

    brands = Brand.all() |> Brand.preload(:drinks)

    changeset = Venue.changeset(venue)

    render(conn, "add_drinks.html",
      brands: brands,
      current_drinks: Enum.map(venue.drinks, fn d -> d.name end),
      changeset: changeset,
      action: venue_path(conn, :update, venue.entry_id)
    )
  end
end
