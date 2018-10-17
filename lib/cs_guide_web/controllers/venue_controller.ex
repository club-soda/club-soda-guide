defmodule CsGuideWeb.VenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue

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
    query = fn s ->
      sub =
        from(mod in Map.get(CsGuide.Resources.Venue.__schema__(:association, s), :queryable),
          distinct: mod.entry_id,
          order_by: [desc: :inserted_at],
          limit: 1,
          select: mod
        )

      from(m in subquery(sub), where: not m.deleted, select: m)
    end

    venue =
      id
      |> Venue.get()
      |> CsGuide.Repo.preload(drinks: query.(:drinks), venue_types: query.(:venue_types))

    render(conn, "show.html", venue: venue)
  end

  def edit(conn, %{"id" => id}) do
    venue = Venue.get(id)
    changeset = Venue.changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    venue = Venue.get(id)

    case Venue.update(venue, venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue updated successfully.")
        |> redirect(to: venue_path(conn, :show, venue.entry_id))

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
end
