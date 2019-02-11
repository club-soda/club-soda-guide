alias CsGuide.Resources.Brand
import Ecto.Changeset

Brand.all()
|> Brand.preload([:drinks, :brand_images])
|> Enum.map(fn brand ->
  if brand.slug == nil do
    slug = Brand.create_slug(brand.name)
    params = brand |> Map.from_struct() |> Map.merge(%{slug: slug})

    brand
    |> Brand.changeset(params)
    |> put_change(:slug, slug)
    |> Brand.update()
    |> case do
      {:ok, _} -> nil
      err -> IO.inspect(err)
    end
  end
end)
