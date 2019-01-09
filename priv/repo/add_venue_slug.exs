alias CsGuide.Resources.Venue

Venue.all()
|> Enum.map(fn v ->
  if v.slug == nil do
    slug = Venue.create_slug(v.venue_name, v.postcode)
    Venue.update(v, %{slug: slug})
  end
end)
