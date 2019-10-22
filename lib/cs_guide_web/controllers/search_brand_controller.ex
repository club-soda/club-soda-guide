defmodule CsGuideWeb.SearchBrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Brand
  alias CsGuide.Images.BrandImage
  alias CsGuide.DiscountCode

  def index(conn, _params) do
    brands =
      Brand.all()
      |> Enum.sort_by(&String.first(&1.name))

    render(conn, "index.html", brands: brands)
  end
end
