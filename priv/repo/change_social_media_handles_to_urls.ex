alias CsGuide.Resources.{Venue, Brand}
brand_preloads = [:brand_images, :drinks]
venue_preloads = [:venue_types, :venue_images, :drinks, :users, :discount_codes]

update_social_url = fn el, social_media_brand, url_template ->
  case Map.get(el, social_media_brand) do
    nil ->
      nil

    social_media_value ->
      if String.starts_with?(social_media_value, "@") do
        cleaned_handle = String.slice(social_media_value, 1..-1)

        String.trim(url_template <> cleaned_handle)
      else
        String.trim(social_media_value)
      end
  end
end

update_website = fn v ->
  case v.website do
    nil ->
      ""

    website ->
      if String.starts_with?(website, "http") == false do
        "http://#{website}"
      else
        website
      end
  end
end

update_urls = fn schema, preloads ->
  elements =
    case schema do
      Venue ->
        Venue.all()
        |> Venue.preload(preloads)
        |> Enum.filter(fn v ->
          !Enum.find(v.venue_types, fn type -> String.downcase(type.name) == "retailer" end)
        end)

      _ ->
        schema.all()
        |> schema.preload(preloads)
    end

  elements
  |> Enum.each(fn v ->
    fb = update_social_url.(v, :facebook, "https://www.facebook.com/")
    twitter = update_social_url.(v, :twitter, "https://www.twitter.com/")
    instagram = update_social_url.(v, :instagram, "https://www.instagram.com/")
    website = update_website.(v)
    updated_links = %{facebook: fb, twitter: twitter, instagram: instagram, website: website}

    attrs =
      case schema do
        Venue ->
          venue = v |> Map.from_struct() |> Map.merge(updated_links)
          if venue.users, do: Map.delete(venue, :users), else: venue

        _ ->
          v |> Map.from_struct() |> Map.merge(updated_links)
      end

    if fb || twitter || instagram || website != "" do
      v
      |> schema.update(attrs)
      |> case do
        {:ok, _} -> nil
        err -> IO.inspect(err)
      end
    end
  end)
end

update_urls.(Venue, venue_preloads)
update_urls.(Brand, brand_preloads)
