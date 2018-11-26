defmodule CsGuide.Resources.CsScore do
  @spirit "Spirit"
  @premixed "Premixed"

  def calculateScore(drinks, num_cocktails) do
    score =
      if Kernel.length(drinks) >= 1 do
        low_alc_score =
          drinks
          |> checkLowAlcDrinks
          |> Enum.reduce(fn score, total -> total + score end)

        med_alc_score =
          drinks
          |> checkMedAlcDrinks

        others_score =
          drinks
          |> Enum.map(fn d ->
            cond do
              isMultipleDrinkTypes(d, @spirit, @premixed) ->
                1

              true ->
                0
            end
          end)
          |> Enum.reduce(fn score, total -> total + score end)

        total_score = low_alc_score + med_alc_score + others_score
      else
        0
      end

    (score + (num_cocktails || 0) * 0.5) |> limitAt5
  end

  defp limitAt5(score) do
    if score > 5 do
      5
    else
      score
    end
  end

  defp checkMedAlcDrinks(drinks) do
    drinks
    |> Enum.map(fn d ->
      if isDrinkType(d, "Soft Drink") do
        {:soft_drink, 0.5}
      else
        if d.abv > 0.5 && isDrinkType(d, "Wine") do
          {:wine, 1}
        else
          if d.abv > 0.5 && isDrinkType(d, "Beer") do
            {:beer, 1}
          else
            if isMultipleDrinkTypes(d, "Tonic", "Mixer") do
              {:tonic_mixer, 0.5}
            else
              {:none, 0}
            end
          end
        end
      end
    end)
    |> Enum.reduce(%{}, fn {x, v}, acc ->
      Map.update(acc, x, v, &(&1 + v))
    end)
    |> Enum.reduce(0, fn {_, score}, total ->
      if score > 1 do
        total + 1
      else
        total + score
      end
    end)
  end

  defp isDrinkType(d, drink_type) do
    Enum.find_value(d.drink_types, false, fn t ->
      t.name == drink_type
    end)
  end

  defp checkLowAlcDrinks(drinks) do
    drinks
    |> Enum.map(fn d ->
      if d.abv <= 0.5 && isMultipleDrinkTypes(d, "Beer", "Wine", "Cider") do
        1
      else
        0
      end
    end)
  end

  defp isMultipleDrinkTypes(d, type1, type2, type3 \\ "") do
    Enum.find_value(d.drink_types, false, fn t ->
      t.name == type1 || t.name == type2 || t.name == type3
    end)
  end
end
