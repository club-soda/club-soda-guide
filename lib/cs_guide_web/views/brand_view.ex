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
  end

  def query(sch) do
    sub =
      from(s in sch,
        distinct: s.entry_id,
        order_by: [desc: :inserted_at],
        select: s
      )

    from(m in subquery(sub), where: not m.deleted, select: m)
  end
end
