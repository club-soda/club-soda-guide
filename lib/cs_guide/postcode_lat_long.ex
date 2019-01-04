defmodule CsGuide.PostcodeLatLong do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.Venue
  import Ecto.Query
  use GenServer

  @zip_file_name "postcodes.zip"
  @zip_file_name_charlist String.to_charlist(@zip_file_name)
  @postcode_file_charlist 'ukpostcodes.csv'

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: PostcodeCache)
  end

  def init(initial_state) do
    postcode_cache = :ets.new(:postcode_cache, [:set, :protected, :named_table])
    store_postcodes_in_ets(postcode_cache)
    {:ok, initial_state}
  end

  defp store_postcodes_in_ets(ets) do
    if File.exists?("ukpostcodes.csv") do
      IO.inspect("Postcode file exists, storing with ets")
      get_postcodes_from_csv("ukpostcodes.csv", ets)
    else
      IO.inspect("Postcode file does not exist. Creating file...")
      case create_csv_file() do
        :ok ->
          IO.inspect("Removed zip file. Storing postcodes with ets")
          get_postcodes_from_csv("ukpostcodes.csv", ets)

        error ->
          error
      end
    end
  end

  def nearest_venues(lat, long, distance \\ 5_000)
  def nearest_venues(lat, long, distance) when distance < 30_000 do
    case venues_within_distance(distance, lat, long) do
      [] -> nearest_venues(lat, long, distance + 5_000)
      venues -> venues
    end
  end
  def nearest_venues(_, _, _), do: []

  defp venues_within_distance(distance, lat, long) do
    Venue
    |> where([venue], venue.deleted == false)
    |> where(
      [venue],
      fragment(
        "? @> ?",
        fragment(
          "earth_box(?, ?)",
          fragment("ll_to_earth(?, ?)", ^lat, ^long),
          ^distance
        ),
        fragment("ll_to_earth(?,?)", venue.lat, venue.long)
      )
    )
    |> select([venue], %{
      venue
      | distance:
          fragment(
            "? as distance",
            fragment(
              "? <@> ?",
              fragment("point(?, ?)", ^long, ^lat),
              fragment("point(?, ?)", venue.long, venue.lat)
            )
          )
    })
    |> distinct([v], [asc: fragment("distance"), asc: :entry_id])
    |> CsGuide.Repo.all()
  end

  defp get_postcodes_from_csv(csv, ets) do
    csv
    |> File.read!()
    |> csv_to_ets(~w(nil postcode latitude longitude)a, ets)
  end

  defp csv_to_ets(csv, columns, ets) do
    csv
    |> CSV.parse_string()
    |> Enum.map(fn data ->
        columns
        |> Enum.zip(data)
        |> Enum.filter(fn {k, _v} -> not is_nil(k) end)
        |> Enum.into(%{})
        |> add_postcode_latlong_to_ets(ets)
    end)
  end

  defp add_postcode_latlong_to_ets(map, ets) do
    postcode = String.replace(map.postcode, " ", "")

    :ets.insert_new(ets, {postcode, map.latitude, map.longitude})
  end

  # Gets zip file from github and saves the response to body then writes the
  # zip file to allow it to be unzipped so the csv can be extracted
  def create_csv_file() do
    zip_file_url = "https://raw.githubusercontent.com/dwyl/uk-postcodes-latitude-longitude-complete-csv/master/ukpostcodes.csv.zip"
    %HTTPoison.Response{body: body} = HTTPoison.get!(zip_file_url)

    case File.write(@zip_file_name, body) do
      :ok ->
        IO.inspect("Created zip file")
        unzip_file_name()

      error ->
        error
    end
  end

  # Helper to unzip file and only take ukpostcodes.csv
  # If file is succesfully unziped then it deletes the zip file
  defp unzip_file_name do
    case :zip.extract(@zip_file_name_charlist, [{:file_list, [@postcode_file_charlist]}]) do
      {:ok, _fileList} ->
        IO.inspect("Postcodes successfully unzipped")
        File.rm(@zip_file_name)

      error ->
        error
    end
  end
end
