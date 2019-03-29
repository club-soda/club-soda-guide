defmodule CsGuideWeb.CsvController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}
  alias CsGuide.Categories.{DrinkType, DrinkStyle, VenueType}
  alias CsGuide.{Repo, SearchLog}
  import Ecto.Query

  def export(conn, params) do
     case params["data"] do
        "venues" -> venues_csv_content(conn)

        "venues-drinks" -> venues_drinks_csv_content(conn)

        "drinks" -> drinks_csv_content(conn)

        "brands" -> brands_csv_content(conn)

        "brands-drinks" -> brands_drinks_csv_content(conn)

        "drink-types" -> drink_types_csv_content(conn)

        "drink-styles" -> drink_styles_csv_content(conn)

        "venue-types" -> venue_types_csv_content(conn)

        "search-log" -> search_log_csv_content(conn)

        _ ->  conn
              |> put_status(:not_found)
              |> put_view(CsGuideWeb.StaticPageView)
              |> render("404.html")
     end

  end

# VENUES

  defp venues_csv_content(conn) do
    venues = Venue.all() |> Enum.map(&venue_csv_data(&1))
    |> CSV.encode(headers: [ :venue_name,
                            :postcode,
                            :phone_number,
                            :cs_score,
                            :description,
                            :num_cocktails,
                            :website,
                            :address,
                            :city,
                            :twitter,
                            :instagram,
                            :facebook,
                            :favourite,
                            :lat,
                            :long,
                            :slug,
                            :inserted_at,
                            :updated_at
                            ])
    |> Enum.to_list
    |> to_string
    conn

    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"venues.csv\"")
    |> send_resp(200, venues)
  end

  defp venue_csv_data(venue) do
    %{
      venue_name: venue.venue_name,
      postcode: venue.postcode,
      phone_number: venue.phone_number,
      cs_score: venue.cs_score,
      description: venue.description,
      num_cocktails: venue.num_cocktails,
      website: venue.website,
      address: venue.address,
      city: venue.city,
      twitter: venue.twitter,
      instagram: venue.instagram,
      facebook: venue.facebook,
      favourite: venue.favourite,
      lat: venue.lat,
      long: venue.long,
      slug: venue.slug,
      inserted_at: venue.inserted_at,
      updated_at: venue.updated_at
     }
  end

# Venues and Drinks
  defp venues_drinks_csv_content(conn) do
    venues_drinks = Venue.all()
    |> Venue.preload([:drinks])
    |> Enum.map(&venues_drinks_csv_data(&1))
    |> Enum.flat_map(&(&1))
    |> CSV.encode(headers: [ :venue_id, :venue_name, :drink_id, :drink_name])
    |> Enum.to_list
    |> to_string
    conn

    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"venues_drinks.csv\"")
    |> send_resp(200, venues_drinks)
  end

  defp venues_drinks_csv_data(v) do
    v.drinks
    |> Enum.map(fn(d) ->
      %{
        venue_id: v.entry_id,
        venue_name: v.venue_name,
        drink_id: d.entry_id,
        drink_name: d.name
      }
    end)
  end


# Drinks

  defp drinks_csv_content(conn) do
    drinks = Drink.all()
    |> Drink.preload([:drink_types, :drink_styles])
    |> Enum.map(&drink_csv_data(&1))
    |> CSV.encode(headers: [ :drink_id,
                             :name,
                             :abv,
                             :description,
                             :weighting,
                             :ingredients,
                             :types,
                             :styles,
                             :inserted_at,
                             :updated_at
                            ])
    |> Enum.to_list
    |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"drinks.csv\"")
    |> send_resp(200, drinks)
  end

  defp drink_csv_data(drink) do
    %{
      drink_id: drink.entry_id,
      name: drink.name,
      abv: drink.abv,
      description: drink.description,
      weighting: drink.weighting,
      ingredients: drink.ingredients,
      types: Enum.map_join(drink.drink_types, ", ", &(&1.name)),
      styles: Enum.map_join(drink.drink_styles, ", ", &(&1.name)),
      inserted_at: drink.inserted_at,
      updated_at: drink.updated_at
     }
  end

# BRANDS
  defp brands_csv_content(conn) do
    brands =
      Brand.all()
      |> Enum.map(&brand_csv_data(&1))
      |> CSV.encode(
        headers: [
          :name,
          :description,
          :logo,
          :website,
          :twitter,
          :instagram,
          :facebook,
          :copy,
          :sold_aldi,
          :sold_amazon,
          :sold_asda,
          :sold_dd,
          :sold_morrisons,
          :sold_ocado,
          :sold_sainsburys,
          :sold_tesco,
          :sold_waitrose,
          :sold_wb,
          :inserted_at,
          :updated_at
        ]
      )
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"brands.csv\"")
    |> send_resp(200, brands)
  end

  defp brand_csv_data(brand) do
    %{
      name: brand.name,
      description: brand.description,
      logo: brand.logo,
      website: brand.website,
      twitter: brand.twitter,
      instagram: brand.instagram,
      facebook: brand.facebook,
      copy: brand.copy,
      sold_aldi: brand.sold_aldi,
      sold_amazon: brand.sold_amazon,
      sold_asda: brand.sold_asda,
      sold_dd: brand.sold_dd,
      sold_morrisons: brand.sold_morrisons,
      sold_ocado: brand.sold_ocado,
      sold_sainsburys: brand.sold_sainsburys,
      sold_tesco: brand.sold_tesco,
      sold_waitrose: brand.sold_waitrose,
      sold_wb: brand.sold_wb,
      inserted_at: brand.inserted_at,
      updated_at: brand.updated_at
    }
  end

# BRANDS and DRINKS

  defp brands_drinks_csv_content(conn) do
    brands = Brand.all()
    |> Brand.preload([:drinks])
    |> Enum.map(&brands_drinks_csv_data(&1))
    |> Enum.flat_map(&(&1))
    |> CSV.encode(headers: [ :brand_id, :brand_name, :drink_id, :drink_name])
    |> Enum.to_list
    |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"brands_drinks.csv\"")
    |> send_resp(200, brands)
  end

  defp brands_drinks_csv_data(brand) do
    brand.drinks
    |> Enum.map(fn(d) ->
      %{
        brand_id: brand.entry_id,
        brand_name: brand.name,
        drink_id: d.entry_id,
        drink_name: d.name
      }
    end)
  end
# DRINK TYPES
  defp drink_types_csv_content(conn) do
    brands = DrinkType.all() |> Enum.map(fn drink_type ->
      %{
        name: drink_type.name,
        inserted_at: drink_type.inserted_at,
        updated_at: drink_type.updated_at
      }
    end)
    |> CSV.encode(headers: [ :name, :inserted_at, :updated_at])
    |> Enum.to_list
    |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"drink_types.csv\"")
    |> send_resp(200, brands)
  end

# DRINK STYLES
  defp drink_styles_csv_content(conn) do
    brands = DrinkStyle.all() |> Enum.map(fn drink_style ->
      %{
        name: drink_style.name,
        inserted_at: drink_style.inserted_at,
        updated_at: drink_style.updated_at
      }
    end)
    |> CSV.encode(headers: [ :name, :inserted_at, :updated_at])
    |> Enum.to_list
    |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"drink_styles.csv\"")
    |> send_resp(200, brands)
  end

# VENUE TYPES
    defp venue_types_csv_content(conn) do
      brands = VenueType.all() |> Enum.map(fn venue_type ->
        %{
          name: venue_type.name,
          inserted_at: venue_type.inserted_at,
          updated_at: venue_type.updated_at
        }
      end)
      |> CSV.encode(headers: [ :name, :inserted_at, :udpated_at])
      |> Enum.to_list
      |> to_string

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"venue_types.csv\"")
      |> send_resp(200, brands)
    end

  # Search Log
  defp search_log_csv_content(conn) do
    searches_log = SearchLog |> order_by(desc: :inserted_at) |> Repo.all() 
    |> Enum.map(fn search ->
      %{
        search: search.search,
        inserted_at: search.inserted_at,
      }
    end)
    |> CSV.encode(headers: [ :search, :inserted_at])
    |> Enum.to_list
    |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"searches_log.csv\"")
    |> send_resp(200, searches_log)
  end

end
