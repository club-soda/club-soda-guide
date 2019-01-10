defmodule CsGuideWeb.CsvController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}

  def export(conn, _params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"A Real CSV.csv\"")
    |> send_resp(200, csv_content())
  end


  defp csv_content do
    Venue.all() |> Enum.map(&venue_csv_data(&1))
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
                            :slug
                            ])
    |> Enum.to_list
    |> to_string
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
      slug: venue.slug
     }
  end
end
