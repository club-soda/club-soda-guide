defmodule CsGuideWeb.BrandView do
  use CsGuideWeb, :view
  use Autoform

  def get_venues(brand) do
    brand.drinks
    |> Enum.map(fn d ->
      d.venues
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> sort_by_cs_score()
  end

  defp sort_by_cs_score(venues) do
    venues
    |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
    |> Enum.chunk_by(fn v ->
      v.cs_score
    end)
    |> Enum.map(fn list -> Enum.shuffle(list) end)
    |> List.flatten()
    |> Enum.slice(0, 4)
  end
end
