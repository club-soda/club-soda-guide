defmodule CsGuide.UpdateCsScore do
  alias CsGuide.Resources.{Venue, Drink}
  import Ecto.Query, only: [from: 2, subquery: 1]

  def update_cs_score(venue, acc) do
    query = fn s, m ->
      sub =
        from(mod in Map.get(m.__schema__(:association, s), :queryable),
          distinct: mod.entry_id,
          order_by: [desc: :updated_at],
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

    if venue.cs_score != calculatedScore && length(venue.drinks) != 0 do
      attrs =
        venue
        |> Map.from_struct()
        |> Map.merge(%{cs_score: calculatedScore})

      attrs = if attrs.users, do: Map.delete(attrs, :users)

      update = Venue.update(venue, attrs)
      case update do
        {:error, changeset} ->
          Map.update!(acc, :errors, &([changeset | &1]))
        _ ->
          Map.update!(acc, :updates, &([{venue.venue_name, venue.entry_id} | &1]))
      end
    else
      acc
    end
  end
end

log_numbers = fn(map) ->
  IO.inspect(length(map.errors), label: "number of errors")
  IO.inspect(length(map.updates), label: "number of updates")
end

CsGuide.Resources.Venue.all()
|> CsGuide.Resources.Venue.preload([:drinks, :venue_types, :users])
|> Enum.reduce(%{errors: [], updates: []}, &CsGuide.UpdateCsScore.update_cs_score(&1, &2))
|> IO.inspect(label: "Updates and errors", limit: :infinity)
|> log_numbers.()
