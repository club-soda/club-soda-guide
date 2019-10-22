defmodule CsGuideWeb.SearchBrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Brand
  alias CsGuide.Images.BrandImage
  alias CsGuide.DiscountCode

  def index(conn, _params) do
    %{true: member_brands, false: brands} =
      Brand.all()
      |> Brand.preload(brand_images: [])
      |> Enum.sort_by(&String.first(&1.name))
      |> Enum.group_by(& &1.member)

    IO.inspect(member_brands)
    render(conn, "index.html", member_brands: member_brands, brands: brands)
  end
end
