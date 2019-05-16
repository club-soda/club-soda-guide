defmodule CsGuide.NewVenues do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.{Brand, Drink, Venue}
  alias CsGuide.Categories.{DrinkType, DrinkStyle, VenueType}

  @venues %{ # should this list be alphabetical?
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
      ~w(venue_name nil address phone_number description website facebook twitter instagram venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17)a,
    bermondsey_pub_company:
      ~w(venue_name parent_company address city postcode phone_number venue_types email description website facebook twitter instagram drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17 drink_18)a,
    craft_union:
      ~w(venue_name address city postcode venue_types parent_company website facebook twitter drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9)a,
  }



  @doc """
  Imports venues from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Venue.insert function. We also
  link with the venue types, creating any that don't already exist in the database.
  """
  def import_venues(csv, filename) do
    csv
    |> csv_to_map(Map.get(@venues, String.slice(filename, 0..-5) |> String.to_existing_atom()))
    |> Enum.reduce([], fn v, acc ->
      {_, venue} = add_link(v, :venue_types, VenueType, :name)

      # extract_postcode assumes address has postcode in-line
      [address, postcode] = case extract_postcode(v.address) do
        [_address] ->
          [v.address, v.postcode]
        list ->
          list
      end

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
                IO.inspect("Brand not found: #{not_found_drink}")
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
          |> sanitise_phone_number(v) # remove spaces from phone_number if set
          |> sanitise_url(v, :website) # downcase, trim & add https:// to url
          |> sanitise_url(v, :twitter)
          |> sanitise_url(v, :facebook)
          |> sanitise_url(v, :instagram)
          |> Map.put(:postcode, postcode)
          |> Map.put(:address, String.trim(address))
          |> add_drinks_to_map(drinks)
          |> add_users_to_map(v)
          |> add_lat_long_to_map(postcode)
          |> Venue.insert()
          |> case do
            {:ok, _} ->
              acc
            err ->
              [err | acc]
          end

        _venue ->
          acc
      end
    end)
    |> IO.inspect(label: "errors")
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

  defp add_drinks_to_map(map, drinks) do
    Map.put(map,
      :drinks,
      Map.new(
        Enum.map(
          drinks,
          fn {d, b} ->
            brand = Brand.get_by(name: b)

            case Drink.get_by(name: d, brand_id: brand.id) do
              nil ->
                IO.inspect("Drink not found: #{d}, brand: #{b}")
                nil

              drink ->
                {drink.entry_id, "on"}
            end
          end
        )
        |> Enum.filter(fn d -> not is_nil(d) end)
      )
    )
  end

  defp add_users_to_map(map, venue) do
    if Map.has_key?(venue, :email) && venue.email != "" do
      Map.put(map, :users, %{"0" => %{"email" => venue.email, "role" => "venue_admin"}})
    else
      map
    end
  end

  # some venues don't have a phone_number so don't attempt to String.replace!
  defp sanitise_phone_number(map, venue) do
    # IO.inspect(map, label: "map")
    # IO.inspect(venue, label: "venue")
    # IO.inspect(Map.equal?(map, venue), label: "map == venue")
    if Map.has_key?(venue, :phone_number) && venue.phone_number != "" do

      Map.update!(map, :phone_number, fn s ->
        to_string(s)
        |> String.replace(" ", "")
        |> String.trim() end)
    else
      map
    end
  end

  defp sanitise_url(map, venue, key) do
    IO.inspect(map, label: "map")
    IO.inspect(venue, label: "venue")

    if Map.has_key?(venue, key) && Map.get(venue, key) != "" do

      url = Map.get(venue, key)
      |> to_string()
      |> String.downcase() # e.g: Name.pubchain.com
      |> String.trim()
      |> String.replace("htttp", "http") # yep this is a thing ...
      |> String.replace(" ", "") # yep people typo spaces in urls ...

      IO.inspect(url, label: "url")

      url = if url =~ "http://" || url =~ "https://" do
        url
      else
        "https://" <> url
      end

      Map.put(map, key, url)
    else
      map
    end
  end




  defp add_lat_long_to_map(venue, postcode) do
    case :ets.lookup(:postcode_cache, String.replace(postcode, " ", "")) do
      [{_postcode, lat, long}] ->
        venue
        |> Map.put(:lat, lat)
        |> Map.put(:long, long)

      _ ->
        venue
    end
  end
end

System.get_env("IMPORT_FILES_DIR")
|> File.ls!()
|> Enum.each(fn f ->
  if f =~ ".csv" do
      CsGuide.NewVenues.import_venues(File.read!("#{System.get_env("IMPORT_FILES_DIR")}/#{f}"), f)
  end
end)
