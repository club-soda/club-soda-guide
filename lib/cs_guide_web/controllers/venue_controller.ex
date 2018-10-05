defmodule CsGuideWeb.VenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    # venues = Resources.list_venues()
    # render(conn, "index.html", venues: venues)
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
        |> redirect(to: venue_path(conn, :show, venue))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    venue =
      id
      |> Venue.get()
      |> CsGuide.Repo.preload([:venue_types, :drinks])

    render(conn, "show.html", venue: venue)
  end

  def edit(conn, %{"id" => id}) do
    # venue = Resources.get_venue!(id)
    # changeset = Resources.change_venue(venue)
    # render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    # venue = Resources.get_venue!(id)

    # case Resources.update_venue(venue, venue_params) do
    #   {:ok, venue} ->
    #     conn
    #     |> put_flash(:info, "Venue updated successfully.")
    #     |> redirect(to: venue_path(conn, :show, venue))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", venue: venue, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    # venue = Resources.get_venue!(id)
    # {:ok, _venue} = Resources.delete_venue(venue)

    # conn
    # |> put_flash(:info, "Venue deleted successfully.")
    # |> redirect(to: venue_path(conn, :index))
  end
end
