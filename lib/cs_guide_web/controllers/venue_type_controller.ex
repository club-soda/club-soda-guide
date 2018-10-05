defmodule CsGuideWeb.VenueTypeController do
  use CsGuideWeb, :controller

  alias CsGuide.Categories.VenueType

  def index(conn, _params) do
    # venue_type = Categories.list_venue_type()
    # render(conn, "index.html", venue_type: venue_type)
  end

  def new(conn, _params) do
    changeset = VenueType.changeset(%VenueType{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue_type" => venue_type_params}) do
    case VenueType.insert(venue_type_params) do
      {:ok, venue_type} ->
        conn
        |> put_flash(:info, "Venue types created successfully.")
        |> redirect(to: venue_type_path(conn, :show, venue_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    # venue_type = Categories.get_venue_type!(id)
    # render(conn, "show.html", venue_type: venue_type)
  end

  def edit(conn, %{"id" => id}) do
    # venue_type = Categories.get_venue_type!(id)
    # changeset = Categories.change_venue_type(venue_type)
    # render(conn, "edit.html", venue_type: venue_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "venue_type" => venue_type_params}) do
    # venue_type = Categories.get_venue_type!(id)

    # case Categories.update_venue_type(venue_type, venue_type_params) do
    #   {:ok, venue_type} ->
    #     conn
    #     |> put_flash(:info, "Venue types updated successfully.")
    #     |> redirect(to: venue_type_path(conn, :show, venue_type))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", venue_type: venue_type, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    # venue_type = Categories.get_venue_type!(id)
    # {:ok, _venue_type} = Categories.delete_venue_type(venue_type)

    # conn
    # |> put_flash(:info, "Venue types deleted successfully.")
    # |> redirect(to: venue_type_path(conn, :index))
  end
end
