defmodule CsGuide.PostcodeLatLong do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.Venue
  import Ecto.Query
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: PostcodeCache)
  end

  def init(initial_state) do
    postcode_cache = :ets.new(:postcode_cache, [:set, :protected, :named_table])
    store_postcodes_in_ets(postcode_cache)
    {:ok, initial_state}
  end

  defp store_postcodes_in_ets(ets) do
    file_path = Map.fetch!(System.get_env(), "UK_POSTCODES")

    case File.read(file_path) do
      {:ok, _} ->
        get_postcodes_from_csv(file_path, ets)

      {:error, _} ->
        # Currently just logging to tell dev to run the script. We could
        # automate this step by having the app check if the file exists
        # locally first, if so store in ets, else pull file then store in ets.
        # Leaving as is for now.
        IO.inspect("MAKE SURE YOU RUN THE SCRIPT TO DOWNLOAD THE POSTCODE FILE")
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
    |> order_by(desc: :inserted_at)
    |> distinct([v], fragment("distance"))
    |> order_by(asc: fragment("distance"))
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
end
