defmodule CsGuideWeb.SearchAllController do
  use CsGuideWeb, :controller
  require Logger

  alias CsGuide.Resources.{Drink, Venue}
  alias CsGuide.PostcodeLatLong
  alias CsGuideWeb.{VenueController, SearchVenueController}

  alias CsGuide.SearchLog
  alias CsGuide.Repo

  def index(conn, params) do
    possible_postcode = params["term"] || ""
    search_term = (params["term"] && String.trim(params["term"])) || ""
    # insert search log
    if search_term != "" do
      changeset = SearchLog.changeset(%SearchLog{}, %{search: search_term })
      case Repo.insert(changeset) do
        {:ok, _struct}       -> Logger.info "search: \"#{params["term"]}\" logged"
        {:error, _changeset} -> Logger.info "search: \"#{params["term"]}\" couldn't be logged"
      end
    end


    case PostcodeLatLong.check_or_cache(possible_postcode) do
      {:ok, {lat, long}} ->
        conn
        |> redirect(
          to: search_venue_path(conn, :index, ll: "#{lat},#{long}", postcode: possible_postcode)
        )

      {:error, _} ->
        search_by_text(conn, params)
    end
  end

  defp search_by_text(conn, params) do
    venues =
      Venue.all()
      |> Venue.preload([:venue_types, :venue_images])
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type ->
          String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
        end)
      end)
      |> Enum.sort_by(&{5 - &1.cs_score, &1.venue_name})
      |> Enum.map(&VenueController.sort_images_by_most_recent/1)
      |> Enum.map(&SearchVenueController.selectPhotoNumber1/1)

    venue_cards = Enum.map(venues, fn v -> Venue.get_venue_card(v) end)

    drinks =
      Drink.all()
      |> Drink.preload([:brand, :drink_types, :drink_styles, :drink_images])
      |> Enum.sort_by(fn d -> Map.get(d, :weighting, 0) end, &>=/2)



    drink_cards = Enum.map(drinks, fn d -> Drink.get_drink_card(d) end)

    render(conn, "index.html",
      venues: venue_cards,
      drinks: drink_cards,
      term: params["term"] || ""
    )
  end
end
