alias CsGuide.Repo
alias CsGuide.Resources.Venue

update_postcode = fn postcode ->
  if postcode != nil do
    postcode
    |> String.upcase()
    |> String.replace(" ", "")
  end
end

Venue.all()
|> Venue.preload([:venue_types, :venue_images, :drinks, :users])
|> Enum.each(fn venue ->
  postcode = update_postcode.(venue.postcode)

  if venue.lat == nil do
    case :ets.lookup(:postcode_cache, postcode) do
      [{_postcode, lat, long}] ->
        attrs = venue |> Map.from_struct() |> Map.merge(%{lat: lat, long: long})

        venue
        |> Venue.update(attrs)

      _ ->
        IO.inspect(~s(#{postcode} postcode not fount in ets))
    end
  end
end)
