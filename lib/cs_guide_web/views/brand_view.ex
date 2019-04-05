defmodule CsGuideWeb.BrandView do
  use CsGuideWeb, :view
  use Autoform

  import Ecto.Query, only: [from: 2, subquery: 1]

  def get_venues(brand) do
    brand.drinks
    |> Enum.map(fn d ->
      d.venues
    end)
    |> List.flatten()
    |> Enum.filter(fn v ->
      String.downcase(v.venue_name) != "drydrinker" &&
        String.downcase(v.venue_name) != "wisebartender"
    end)
    |> Enum.uniq()
  end

  def get_initial_venues(venues) do
    venues
    |> Enum.take(20)
  end

  def get_see_more_venues(venues) do
    venues
    |> get_venues_over_n(20)
  end

  def get_venues_over_n(venues, n) do
    venues
    |> Enum.split(n)
    |> Tuple.to_list()
    |> Enum.at(1)
  end

  def any_type?(brand, type) do
    venues = get_venues(brand)

    types =
      venues
      |> Enum.flat_map(& &1.venue_types)
      |> Enum.map(&String.downcase(&1.name))

    Enum.member?(types, type)
  end

  def brand_sold?(brand) do
    brand.sold_aldi || brand.sold_asda || brand.sold_dd || brand.sold_morrisons ||
      brand.sold_sainsburys || brand.sold_tesco || brand.sold_waitrose || brand.sold_wb ||
      brand.sold_amazon || brand.sold_ocado
  end

  def query(sch) do
    sub =
      from(s in sch,
        distinct: s.entry_id,
        order_by: [desc: :updated_at],
        select: s
      )

    from(m in subquery(sub), where: not m.deleted, select: m)
  end
end
