defmodule CsGuide.Images.BrandImage do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "brand_images" do
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:one, :boolean)

    belongs_to(:brand, CsGuide.Resources.Brand)

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:brand_id, :one])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> CsGuide.Resources.add_file_extension(attrs)
    |> CsGuide.Resources.put_belongs_to_assoc(
      attrs,
      :brand,
      :brand_id,
      CsGuide.Resources.Brand,
      :entry_id
    )
    |> __MODULE__.changeset(attrs)
    |> CsGuide.Repo.insert()
  end
end
