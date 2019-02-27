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
    |> sort_by_cs_score()
  end

  def filter_retailer_wholesaler(venues) do
    venues
    |> Enum.filter(fn v ->
      !Enum.any?(v.venue_types, fn t ->
        String.downcase(t.name) == "retailer" || String.downcase(t.name) == "wholesaler"
      end)
    end)
  end

  def get_venues_over_forty(venues) do
    venues
    |> Enum.sort()
    |> Enum.split(1)
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
      brand.sold_amazon
  end

  defp sort_by_cs_score(venues) do
    venues
    |> Enum.sort(fn v1, v2 -> v1.cs_score >= v2.cs_score end)
    |> Enum.chunk_by(fn v ->
      v.cs_score
    end)
    |> Enum.map(fn list -> Enum.shuffle(list) end)
    |> List.flatten()
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
