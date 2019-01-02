defmodule CsGuideWeb.RetailerController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailers" end)
      end)
      |> Enum.sort_by(& &1.venue_name)

    render(conn, "index.html", venues: venues)
  end

  def new(conn, _params) do
    changeset = Venue.retailer_changeset(%Venue{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    venue_params = Map.put(venue_params, "venue_types", %{"Retailers" => "on"})

    case Venue.retailer_insert(venue_params) do
      {:ok, venue} ->
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

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    venue =
      Venue.get(id)
      |> Venue.preload([:venue_types, :venue_images, :drinks])

    venue_params =
      venue_params
      |> Map.put("drinks", venue.drinks)
      |> Map.put("venue_types", %{"Retailers" => "on"})

    case Venue.retailer_update(venue, venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Retailer updated successfully.")
        |> redirect(to: retailer_path(conn, :index))

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
      |> put_flash(:info, "Retailer updated successfully.")
      |> redirect(to: retailer_path(conn, :index))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end
end
