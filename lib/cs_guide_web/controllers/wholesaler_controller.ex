defmodule CsGuideWeb.WholesalerController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "wholesalers" end)
      end)
      |> Enum.sort_by(& &1.venue_name)

    render(conn, "index.html", venues: venues)
  end

  def new(conn, _params) do
    changeset = Venue.retailer_changeset(%Venue{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    venue_params = Map.put(venue_params, "venue_types", %{"Wholesalers" => "on"})

    case Venue.retailer_insert(venue_params) do
      {:ok, _venue} ->
        conn
        |> put_flash(:info, "Wholesaler created successfully.")
        |> redirect(to: wholesaler_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    venue = Venue.get(id) |> Venue.preload(:venue_types)
    changeset = Venue.retailer_changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    venue =
      Venue.get(id)
      |> Venue.preload([:venue_types, :venue_images, :drinks])

    venue_params =
      venue_params
      |> Map.put("drinks", venue.drinks)
      |> Map.put("venue_types", %{"Wholesalers" => "on"})

    case Venue.retailer_update(venue, venue_params) do
      {:ok, _venue} ->
        conn
        |> put_flash(:info, "Wholesaler updated successfully.")
        |> redirect(to: wholesaler_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end
end
