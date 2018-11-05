defmodule CsGuide.Import do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.{Brand, Drink, Venue}
  alias CsGuide.Categories.{DrinkType, DrinkStyle, VenueType}

  def drinks(csv) do
    csv
    |> csv_to_map(~w(name brand image abv description drink_types style ingredients)a)
    |> Enum.each(fn d ->
      if d.name != "" do
        {_, drink} =
          Map.get_and_update(d, :brand, fn b ->
            {b, Map.new([{b, "on"}])}
          end)
          |> elem(1)
          |> add_link(:drink_types, DrinkType, :name)

        case Drink.insert(drink) do
          {:ok, _} -> nil
          err -> IO.inspect(err)
        end
      end
    end)
  end

  def brands(csv) do
    csv
    |> csv_to_map(~w(name nil member description nil nil nil nil link nil)a)
    |> Enum.each(&Brand.insert/1)
  end

  def venues_1(csv) do
    csv
    |> csv_to_map(
      ~w(nil venue_name nil description venue_types nil nil nil nil nil nil nil address city region country postcode latitude longitude opening_hours phone_number email website twitter facebook instagram)a
    )
    |> Enum.each(fn v ->
      if v.venue_name != "" do
        {_, venue} = add_link(v, :venue_types, VenueType, :name)

        venue
        |> Map.update!(:venue_name, &String.trim/1)
        |> Venue.insert()
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
      |> Venue.update(v)
      |> case do
        {:ok, _} -> nil
        err -> IO.inspect(err)
      end
    end)
  end

  defp csv_to_map(csv, columns) do
    csv
    |> CSV.parse_string()
    |> Enum.map(fn data ->
      columns
      |> Enum.zip(data)
      |> Enum.filter(fn {k, v} -> not is_nil(k) end)
      |> Map.new()
    end)
  end

  def add_link(d, column, queryable, field) do
    Map.get_and_update(d, column, fn t ->
      new =
        String.split(t, ",")
        |> Enum.map(fn dt ->
          case queryable.get_by([{field, dt}]) do
            nil ->
              queryable.insert(%{} |> Map.put(field, dt))
              {dt, "on"}

            type ->
              {Map.get(type, field), "on"}
          end
        end)
        |> Map.new()

      {t, new}
    end)
  end

  def get_column_num(csv, name) do
    CSV.parse_string(csv, headers: false)
    |> List.first()
    |> Enum.find_index(fn e -> e == name end)
  end
end
