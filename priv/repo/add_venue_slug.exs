alias CsGuide.Resources.Venue

Venue.all()
|> Enum.map(fn v ->
  slug = Venue.create_slug(v.venue_name, v.postcode)
  Venue.update(v, %{slug: slug})
end)
