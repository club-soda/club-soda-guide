defmodule CsGuide.PostcodeLatLong do
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
    case Mix.env do
      :test ->
        IO.puts("Skipping postcode storage")
        # This can be changed in the future. Just didn't want to have to clone
        # csv file everytime that we run tests. File is currently being used
        # to run priv/repo/add_lat_long_to_venue.exs. If we build in
        # functionality in the future that checks to see if entered postcodes
        # (venue creation for example) are correct, then we can check them
        # against the cache. For testing at that point we can create a smaller
        # csv file which we can use to test with.
      _ ->
        :ets.new(:postcode_cache, [:set, :protected, :named_table])
        store_postcodes_in_ets()
    end
    {:ok, initial_state}
  end

  defp store_postcodes_in_ets do
    if File.exists?("ukpostcodes.csv") do
      IO.inspect("Postcode file exists, storing with ets")
      postcodes_from_csv_to_ets("ukpostcodes.csv")
    else
      IO.inspect("Postcode file does not exist. Creating file...")
      case create_csv_file() do
        :ok ->
          IO.inspect("Removed zip file. Storing postcodes with ets")
          postcodes_from_csv_to_ets("ukpostcodes.csv")

        error ->
          error
      end
    end
  end

  defp postcodes_from_csv_to_ets(csv) do
    db_prefix_list =
      Venue.all()
      |> Enum.map(&(&1.postcode))
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(&String.split(&1, " ") |> Enum.at(0))
      |> Enum.uniq()

    csv
    |> File.stream!()
    |> Enum.each(fn(str) ->
      [_, postcode, lat, long] = String.split(str, ",")
        if postcode != "postcode" do # does not store title line in cache
          [prefix, _] = String.split(postcode, " ")
          if Enum.member?(db_prefix_list, prefix) do # only stores postcodes that have the same prefix as a venue from the db.
            postcode = String.replace(postcode, " ", "")
            long = String.trim(long)

            :ets.insert_new(:postcode_cache, {postcode, lat, long})
          end
        end
    end)
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
    # filters deleted venues
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
    # filters veunes that are within the given distance
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
    # selects all venues 'where' tells it to and adds the :distance key to
    # each (:distance is a virtual field that needs to be added to each venue
    # as the lat, long and distance variables passed in can all change)
    |> distinct([v], [asc: fragment("distance"), asc: :entry_id])
    # filters the results to make sure it returns only venues with a unique
    # combination of distance and entry_id. The reason for the combination is to
    # account for cases where distances could be the same to different venues.
    |> CsGuide.Repo.all()
  end
end
