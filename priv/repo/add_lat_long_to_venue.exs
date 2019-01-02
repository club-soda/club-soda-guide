alias CsGuide.Repo
alias CsGuide.Resources.Venue

Repo.all(Venue)
|> Repo.preload(:venue_types)
|> Enum.each(fn(venue) ->
  if venue.lat == nil do
    postcode =
      venue.postcode
      |> String.upcase()
      |> String.replace(" ", "")

    case :ets.lookup(:postcode_cache, postcode) do
      [{_postcode, lat, long}] ->
        venue
        |> Venue.changeset(%{lat: lat, long: long})
        |> Repo.update!()

      _ ->
        IO.inspect(~s(#{postcode} postcode not fount in ets))
    end
  end
end)
