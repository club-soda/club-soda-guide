defmodule CsGuide.NewVenues do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.{Brand, Drink, Venue}
  alias CsGuide.Categories.{DrinkType, DrinkStyle, VenueType}

  @venues %{
    all_bar_one:
      ~w(venue_name nil address phone_number description website facebook twitter instagram nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11)a,
    yates:
      ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
    common_room:
      ~w(venue_name nil address phone_number email description website facebook twitter venue_types)a,
    town_and_pub:
      ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13)a,
    walkabout:
      ~w(venue_name nil address phone_number description website facebook twitter nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8)a,
    browns:
      ~w(venue_name nil address phone_number description website venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11)a,
    slug_and_lettuce:
      ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
    classic_inns:
      ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
    stonehouse:
      ~w(venue_name nil address phone_number description website facebook instagram twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4)a,
    miller_and_carter:
      ~w(venue_name nil address phone_number description website facebook twitter instagram venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14)a,
    ember_inns:
      ~w(venue_name nil address phone_number description website facebook venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12)a,
    oneills:
      ~w(venue_name nil address phone_number description website facebook twitter nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
    harvester:
      ~w(venue_name nil address phone_number description website facebook twitter instagram nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13)a,
    vintage_inns:
      ~w(venue_name nil address phone_number description website facebook twitter nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13)a,
    sizzling_pubs:
      ~w(venue_name nil address phone_number description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
    nicholsons:
      ~w(venue_name nil address phone_number description website facebook twitter instagram venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17)a
  }

  @doc """
  Imports venues from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Venue.insert function. We also
  link with the venue types, creating any that don't already exist in the database.
  """
  def import_venues(csv, filename) do
    csv
    |> csv_to_map(Map.get(@venues, String.slice(filename, 0..-5) |> String.to_existing_atom()))
    |> Enum.each(fn v ->
      {_, venue} = add_link(v, :venue_types, VenueType, :name)

      [address, postcode] = extract_postcode(v.address)

      drinks =
        Enum.reduce(v, [], fn {key, val}, acc ->
          if key |> to_string |> String.slice(0..5) == "drink_" do
            val
            |> String.split(" ")
            |> Enum.reduce_while("", fn s, b_acc ->
              case Brand.get_by(name: b_acc) do
                nil ->
                  case b_acc do
                    "" -> {:cont, b_acc <> s}
                    _ -> {:cont, b_acc <> " " <> s}
                  end

                b ->
                  brand_name = Map.get(b, :name)
                  brand_size = byte_size(brand_name)
                  <<^brand_name::binary-size(brand_size), " "::binary, drink::binary>> = val
                  {:halt, List.insert_at(acc, -1, {drink, b.name})}
              end
            end)
            |> case do
              drinks when is_list(drinks) ->
                drinks

              not_found_drink ->
                IO.inspect("Drink not found: #{not_found_drink}")
                acc
            end
          else
            acc
          end
        end)

      case Venue.get_by(venue_name: v.venue_name, postcode: postcode) do
        nil ->
          venue
          |> Map.update!(:venue_name, &String.trim/1)
          |> Map.update!(:phone_number, fn s -> String.replace(s, " ", "") |> String.trim() end)
          |> Map.put(:postcode, postcode)
          |> Map.put(:address, String.trim(address))
          |> Map.put(:slug, Venue.create_slug(venue.venue_name, postcode))
          |> Map.put(
            :drinks,
            Map.new(
              Enum.map(
                drinks,
                fn {d, b} ->
                  brand = Brand.get_by(name: b)
                  drink = Drink.get_by(name: d, brand_id: brand.id)
                  {drink.entry_id, "on"}
                end
              )
            )
          )
          |> (fn v ->
                case :ets.lookup(:postcode_cache, String.replace(postcode, " ", "")) do
                  [{_postcode, lat, long}] ->
                    v
                    |> Map.put(:lat, lat)
                    |> Map.put(:long, long)

                  _ ->
                    v
                end
              end).()
          |> Venue.insert()
          |> case do
            {:ok, _} -> nil
            err -> IO.inspect(err)
          end

        ven ->
          ven
          |> Venue.preload([:drinks, :venue_types, :users])
          |> Venue.update(
            ven
            |> Map.drop([:users])
            |> Map.from_struct()
            |> (fn v ->
                  case :ets.lookup(:postcode_cache, String.replace(postcode, " ", "")) do
                    [{_postcode, lat, long}] ->
                      v
                      |> Map.put(:lat, lat)
                      |> Map.put(:long, long)

                    _ ->
                      v
                  end
                end).()
            |> Map.merge(venue)
          )
          |> case do
            {:ok, _} -> nil
            err -> IO.inspect(err)
          end
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
              Map.put(struct(queryable), field, v)
              |> queryable.changeset()
              |> queryable.insert()

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

  defp extract_postcode(str) do
    postcode_regex =
      ~r/((GIR 0AA)|((([A-PR-UWYZ][0-9][0-9]?)|(([A-PR-UWYZ][A-HK-Y][0-9][0-9]?)|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY])))) [0-9][ABD-HJLNP-UW-Z]{2}))/

    Regex.split(postcode_regex, str, include_captures: true, trim: true)
  end
end

System.get_env("IMPORT_FILES_DIR")
|> File.ls!()
|> Enum.each(fn f ->
  CsGuide.NewVenues.import_venues(File.read!("#{System.get_env("IMPORT_FILES_DIR")}/#{f}"), f)
end)
