defmodule CsGuide.Import do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.{Brand, Drink, Venue}
  alias CsGuide.Categories.{DrinkType, DrinkStyle, VenueType}

  def venues_1(csv) do
    csv
    |> csv_to_map(
      ~w(nil venue_name nil description venue_types nil nil nil nil nil nil nil address city region country postcode latitude longitude opening_hours phone_number email website twitter facebook nil nil nil instagram nil)a
    )
    |> Enum.each(fn v ->
      if v.venue_name != "" do
        {_, data} = add_link(v, :venue_types, VenueType, :name)

        Venue.get_by(venue_name: String.trim(v.venue_name))
        |> Venue.preload(:venue_types)
        |> Venue.preload(:users)
        |> (fn venue ->
              case Map.get(venue, :venue_types) do
                [] ->
                  Venue.update(
                    venue,
                    venue |> Map.from_struct() |> Map.put(:venue_types, data.venue_types)
                  )

                other ->
                  {:ok, venue}
              end
            end).()
        |> case do
          {:ok, _} -> nil
          err -> IO.inspect(err)
        end
      end
    end)
  end

  def venues_2(csv) do
    csv
    |> csv_to_map(
      [nil, nil, nil, nil, :venue_name] ++
        List.duplicate(nil, get_column_num(csv, "cf_final_score") - 5) ++ [:cs_score]
    )
    |> Enum.each(fn v ->
      Venue.get_by(venue_name: v.venue_name)
      |> Venue.preload(:venue_types)
      |> Venue.preload(:users)
      |> (fn venue ->
            case venue.cs_score do
              0.0 ->
                Venue.update(
                  venue,
                  venue |> Map.from_struct() |> Map.put(:cs_score, v.cs_score)
                )

              other ->
                {:ok, venue}
            end
          end).()
      |> case do
        {:ok, _} -> nil
        err -> IO.inspect(err)
      end
    end)
  end

  defp add_link(item, column, queryable, field) do
    Map.get_and_update(item, column, fn values ->
      new =
        values
        |> String.split(",")
        |> Enum.map(fn v ->
          case queryable.get_by([{field, v}]) do
            nil ->
              queryable.insert(%{} |> Map.put(field, v))
              {v, "on"}

            type ->
              {Map.get(type, field), "on"}
          end
        end)
        |> Map.new()

      {values, new}
    end)
  end

  defp csv_to_map(csv, columns) do
    csv
    |> CSV.parse_string()
    |> Enum.map(fn data ->
      columns
      |> Enum.zip(data)
      |> Enum.filter(fn {k, _v} -> not is_nil(k) end)
      |> Map.new()
    end)
  end

  defp get_column_num(csv, name) do
    CSV.parse_string(csv, headers: false)
    |> List.first()
    |> Enum.find_index(fn e -> e == name end)
  end
end

File.read!("#{System.get_env("IMPORT_FILES_DIR")}/venues_1.csv") |> CsGuide.Import.venues_1()
File.read!("#{System.get_env("IMPORT_FILES_DIR")}/venues_2.csv") |> CsGuide.Import.venues_2()
