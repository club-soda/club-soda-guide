defmodule CsGuide.Import do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.{Brand, Drink, Venue}
  alias CsGuide.Categories.{DrinkType, DrinkStyle, VenueType}

  @doc """
  Imports drinks from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Drink.insert function. We also
  manually set the brand, and link with the drink types, creating any that don't already exist in the database.
  """
  def drinks(csv) do
    csv
    |> csv_to_map(~w(name brand nil abv description drink_types drink_styles ingredients)a)
    |> Enum.each(fn d ->
      if d.name != "" do
        {_, drink} =
          d
          |> add_link(:drink_types, DrinkType, :name)
          |> elem(1)
          |> add_link(:drink_styles, DrinkStyle, :name)

        case Drink.insert(drink) do
          {:ok, _} -> nil
          err -> IO.inspect(err)
        end
      end
    end)
  end

  @doc """
  Imports brands from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Brand.insert function. Any unused columns
  are mapped to nil, which is then filtered out.
  """
  def brands(csv) do
    csv
    |> csv_to_map(~w(name nil member description nil nil nil nil link nil)a)
    |> Enum.each(&Brand.insert/1)
  end

  @doc """
  Imports venues from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Venue.insert function. We also
  link with the venue types, creating any that don't already exist in the database.
  """
  def venues_1(csv) do
    csv
    |> csv_to_map(
      ~w(nil venue_name nil description venue_types nil nil nil nil nil nil nil address city region country postcode latitude longitude opening_hours phone_number email website twitter facebook nil nil nil instagram)a
    )
    |> Enum.each(fn v ->
      if v.venue_name != "" do
        {_, venue} = add_link(v, :venue_types, VenueType, :name)

        venue
        |> Map.update!(:venue_name, &String.trim/1)
        |> Map.update!(:phone_number, fn s -> String.replace(s, " ", "") |> String.trim() end)
        |> Map.update!(:postcode, &String.trim/1)
        |> Venue.insert()
        |> case do
          {:ok, _} -> nil
          err -> IO.inspect(err)
        end
      end
    end)
  end

  @doc """
  Imports venues from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Venue.insert function. We also
  link with the venue types, creating any that don't already exist in the database.
  """
  def venues_2(csv) do
    csv
    |> csv_to_map(
      [nil, nil, nil, nil, :venue_name] ++
        List.duplicate(nil, get_column_num(csv, "cf_final_score") - 5) ++ [:cs_score]
    )
    |> Enum.each(fn v ->
      Venue.get_by(venue_name: v.venue_name)
      |> Venue.update(v)
      |> case do
        {:ok, _} -> nil
        err -> IO.inspect(err)
      end
    end)
  end

  @doc """
  Imports venues from csv file. The columns are mapped to atoms in our csv_to_map function
  and that map is then inserted into the database using the Venue.insert function. We also
  link with the venue types, creating any that don't already exist in the database. These venues
  are all from the same chain, and as such all serve the same drinks, which we also insert.
  """
  def venues_3(csv) do
    csv
    |> csv_to_map(
      ~w(venue_name nil address phone_number email description website facebook twitter num_cocktails)a
    )
    |> Enum.each(fn v ->
      [address, postcode] = extract_postcode(v.address)

      v
      |> Map.put(:venue_types, "Bars")
      |> Map.put(
        :drinks,
        Map.new([
          {"Nanny State", "on"},
          {"B:Free", "on"},
          {"Sparkling Elderflower", "on"},
          {"Rose Lemonade", "on"},
          {"Ginger Beer", "on"},
          {"Mediterranean Tonic Water", "on"}
        ])
      )
      |> Map.put(:postcode, postcode)
      |> Map.put(:address, String.trim(address))
      |> Map.put(:cs_score, 5.0)
      |> add_link(:venue_types, VenueType, :name)
      |> elem(1)
      |> Venue.insert()
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

  defp get_column_num(csv, name) do
    CSV.parse_string(csv, headers: false)
    |> List.first()
    |> Enum.find_index(fn e -> e == name end)
  end

  defp extract_postcode(str) do
    postcode_regex =
      ~r/((GIR 0AA)|((([A-PR-UWYZ][0-9][0-9]?)|(([A-PR-UWYZ][A-HK-Y][0-9][0-9]?)|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY])))) [0-9][ABD-HJLNP-UW-Z]{2}))/

    Regex.split(postcode_regex, str, include_captures: true, trim: true)
  end
end

File.read!("#{System.get_env("IMPORT_FILES_DIR")}/brands.csv") |> CsGuide.Import.brands()
File.read!("#{System.get_env("IMPORT_FILES_DIR")}/drinks.csv") |> CsGuide.Import.drinks()
File.read!("#{System.get_env("IMPORT_FILES_DIR")}/venues_1.csv") |> CsGuide.Import.venues_1()
File.read!("#{System.get_env("IMPORT_FILES_DIR")}/venues_2.csv") |> CsGuide.Import.venues_2()
File.read!("#{System.get_env("IMPORT_FILES_DIR")}/venues_3.csv") |> CsGuide.Import.venues_3()
