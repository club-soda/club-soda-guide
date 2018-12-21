defmodule CsGuide.UpdateCsScore do
  alias CsGuide.Resources.{Venue, Drink}
  import Ecto.Query, only: [from: 2, subquery: 1]

  def update_cs_score(venue) do
    query = fn s, m ->
      sub =
        from(mod in Map.get(m.__schema__(:association, s), :queryable),
          distinct: mod.entry_id,
          order_by: [desc: :inserted_at],
          select: mod
        )

      from(m in subquery(sub), where: not m.deleted, select: m)
    end

    calculatedScore =
      CsGuide.Resources.CsScore.calculateScore(
        venue.drinks
        |> CsGuide.Repo.preload(drink_types: query.(:drink_types, Drink)),
        venue.num_cocktails
      )

    if venue.cs_score != calculatedScore do
      Venue.update(venue, Map.put( %{drinks: venue.drinks}, :cs_score, calculatedScore ) )
    end
  end
end

CsGuide.Resources.Venue.all()
|> CsGuide.Resources.Venue.preload(:drinks)
|> Enum.map(&(CsGuide.UpdateCsScore.update_cs_score(&1)))
