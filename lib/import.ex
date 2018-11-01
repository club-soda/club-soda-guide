defmodule CsGuide.Import do
  alias NimbleCSV.RFC4180, as: CSV
  alias CsGuide.Resources.{Brand, Drink}
  alias CsGuide.Categories.{DrinkType, DrinkStyle}

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
          |> Map.get_and_update(drink, :drink_types, fn t ->
            new =
              String.split(t, ",")
              |> Enum.map(fn dt ->
                case DrinkType.get_by(name: dt) do
                  nil ->
                    DrinkType.insert(%{name: dt})
                    {dt, "on"}

                  type ->
                    {type.name, "on"}
                end
              end)
              |> Map.new()

            {t, new}
          end)

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
end
