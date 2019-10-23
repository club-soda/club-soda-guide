defmodule CsGuideWeb.SearchBrandController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Brand

  def index(conn, _params) do
    brands =
      Brand.all()
      |> Brand.preload(brand_images: [])
      |> Enum.sort_by(&String.first(&1.name))
      |> Enum.group_by(& &1.member)

    {members, non_members} =
      case brands do
        %{true: members, false: non_members} -> {members, non_members}
        %{true: members} -> {members, []}
        %{false: non_members} -> {[], non_members}
        _ -> {[], []}
      end

    render(conn, "index.html", member_brands: members, brands: non_members)
  end
end
