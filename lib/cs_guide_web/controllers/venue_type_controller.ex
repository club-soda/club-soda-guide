defmodule CsGuideWeb.VenueTypeController do
  use CsGuideWeb, :controller

  alias CsGuide.Categories.VenueType

  def index(conn, _params) do
    venue_types = VenueType.all()
    render(conn, "index.html", venue_types: venue_types)
  end

  def new(conn, _params) do
    changeset = VenueType.changeset(%VenueType{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue_type" => venue_type_params}) do
    case %VenueType{} |> VenueType.changeset(venue_type_params) |> VenueType.insert() do
      {:ok, venue_type} ->
        conn
        |> put_flash(:info, "Venue types created successfully.")
        |> redirect(to: venue_type_path(conn, :show, venue_type.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    venue_type = VenueType.get(id)
    render(conn, "show.html", venue_type: venue_type)
  end

  def edit(conn, %{"id" => id}) do
    venue_type = VenueType.get(id)
    changeset = VenueType.changeset(venue_type)
    render(conn, "edit.html", venue_type: venue_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "venue_type" => venue_type_params}) do
    venue_type = VenueType.get(id)

    case venue_type |> VenueType.changeset(venue_type_params) |> VenueType.update() do
      {:ok, venue_type} ->
        conn
        |> put_flash(:info, "Venue types updated successfully.")
        |> redirect(to: venue_type_path(conn, :show, venue_type.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue_type: venue_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    venue_type = VenueType.get(id)
    {:ok, _venue_type} = VenueType.delete(venue_type)

    conn
    |> put_flash(:info, "Venue types deleted successfully.")
    |> redirect(to: venue_type_path(conn, :index))
  end

end
