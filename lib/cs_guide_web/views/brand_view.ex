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
    |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
    |> Enum.slice(0, 4)
  end
end
