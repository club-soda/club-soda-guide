alias CsGuide.Resources.Venue

Venue.all()
|> Venue.preload([:venue_types, :venue_images, :drinks, :users])
|> Enum.map(fn v ->
  if v.slug == nil do
    slug = Venue.create_slug(v.venue_name, v.postcode)

    attrs = v |> Map.from_struct() |> Map.merge(%{slug: slug})
    attrs = if attrs.users, do: Map.delete(attrs, :users)

    Venue.update(v, attrs)
  end
end)
