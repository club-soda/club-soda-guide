alias CsGuide.Resources.Venue

Venue.all()
|> Venue.preload([:venue_types, :venue_images, :drinks, :users])
|> Enum.map(fn v ->
  if v.slug == nil do
    attrs = Map.from_struct(v)
    attrs = if attrs.users, do: Map.delete(attrs, :users)

    Venue.update(v, attrs)
    |> case do
      {:ok, _} -> nil
      err -> IO.inspect(err)
    end
  end
end)
