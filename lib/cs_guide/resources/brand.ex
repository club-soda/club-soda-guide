defmodule CsGuide.Resources.Brand do
  use Ecto.Schema
  use Alog
  alias CsGuide.Repo
  alias CsGuide.Resources
  import Ecto.Changeset

  schema "brands" do
    field(:name, :string)
    field(:description, Fields.DescriptionPlaintextUnlimited)
    field(:member, :boolean, default: false)
    field(:logo, :string)
    field(:website, Fields.Url)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:twitter, Fields.Url)
    field(:instagram, Fields.Url)
    field(:facebook, Fields.Url)
    field(:copy, Fields.DescriptionPlaintextUnlimited)
    field(:sold_aldi, :boolean, default: false)
    field(:sold_amazon, :boolean, default: false)
    field(:sold_asda, :boolean, default: false)
    field(:sold_dd, :boolean, default: false)
    field(:sold_morrisons, :boolean, default: false)
    field(:sold_sainsburys, :boolean, default: false)
    field(:sold_tesco, :boolean, default: false)
    field(:sold_waitrose, :boolean, default: false)
    field(:sold_wb, :boolean, default: false)

    has_many(:drinks, CsGuide.Resources.Drink)
    has_many(:brand_images, CsGuide.Images.BrandImage)

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [
      :name,
      :description,
      :deleted,
      :website,
      :logo,
      :member,
      :twitter,
      :instagram,
      :facebook,
      :copy,
      :sold_aldi,
      :sold_amazon,
      :sold_asda,
      :sold_dd,
      :sold_morrisons,
      :sold_sainsburys,
      :sold_tesco,
      :sold_waitrose,
      :sold_wb
    ])
    |> validate_required([:name])
  end

  def update(%__MODULE__{} = item, attrs) do
    item
    |> __MODULE__.preload(__MODULE__.__schema__(:associations))
    |> Map.put(:id, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :entry_id)
    |> Repo.insert()
  end
end
