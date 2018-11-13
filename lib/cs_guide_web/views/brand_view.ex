defmodule CsGuideWeb.BrandView do
  use CsGuideWeb, :view
  use Autoform
  alias CsGuideWeb.PageController

  def get_venues(brand) do
    brand.drinks
    |> Enum.map(fn d ->
      d.venues
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> PageController.sort_by_cs_score()
  end
end
