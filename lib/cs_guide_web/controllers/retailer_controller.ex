defmodule CsGuideWeb.RetailerController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.{Venue, Brand}

  # =====================================
  # Was being imported for query that was not being used
  # import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailer" end)
      end)
      |> Enum.sort_by(& &1.venue_name)

    render(conn, "index.html", venues: venues)
  end

  def new(conn, _params) do
    changeset = Venue.retailer_changeset(%Venue{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    venue_params = Map.put(venue_params, "venue_types", %{"Retailer" => "on"})

    case Venue.retailer_insert(venue_params) do
      {:ok, _venue} ->
        conn
        |> put_flash(:info, "Retailer created successfully.")
        |> redirect(to: retailer_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    venue = Venue.get(id) |> Venue.preload(:venue_types)
    changeset = Venue.retailer_changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{
        "id" => id,
        "venue" => venue = %{"drinks" => drinks}
      })
      when map_size(venue) <= 2 do
    venue =
      Venue.get(id)
      |> Venue.preload([:venue_types, :venue_images, :drinks, :users])

    venue_params =
      venue
      |> Map.from_struct()
      |> Map.drop([:users])
      |> Map.put(:drinks, drinks)

    do_update(conn, venue, venue_params)
  end

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    venue =
      Venue.get(id)
      |> Venue.preload([:venue_types, :venue_images, :drinks])

    venue_params =
      venue_params
      |> Map.put("drinks", venue.drinks)
      |> Map.put("venue_types", %{"Retailer" => "on"})

    case Venue.retailer_update(venue, venue_params) do
      {:ok, _venue} ->
        conn
        |> put_flash(:info, "Retailer updated successfully.")
        |> redirect(to: retailer_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end

  def add_drinks(conn, %{"id" => id}) do
    venue =
      Venue.get(id)
      |> Venue.preload(drinks: [:brand], venue_types: [])

    brands = Brand.all() |> Brand.preload(:drinks)

    changeset = Venue.retailer_changeset(venue)

    render(conn, "add_drinks.html",
      brands: brands,
      current_drinks: Enum.map(venue.drinks, fn d -> d.entry_id end),
      changeset: changeset,
      action: retailer_path(conn, :update, id)
    )
  end

  defp do_update(conn, venue, venue_params) do
    # This query doesn't appear to be used. Seems a little odd. No tests are
    # failing when code is commented out. Will look into this.
    # =====================================
    # query = fn s, m ->
    #   sub =
    #     from(mod in Map.get(m.__schema__(:association, s), :queryable),
    #       distinct: mod.entry_id,
    #       order_by: [desc: :updated_at],
    #       select: mod
    #     )
    #
    #   from(m in subquery(sub), where: not m.deleted, select: m)
    # end

    with {:ok, venue} <- Venue.retailer_update(venue, venue_params),
         {:ok, _venue} <-
           Venue.retailer_update(
             venue,
             venue_params
           ) do
      conn
      |> put_flash(:info, "Retailer updated successfully.")
      |> redirect(to: retailer_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end
end
