defmodule CsGuide.Resources.Brand do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "brands" do
    field(:name, :string)
    field(:description, Fields.DescriptionPlaintextUnlimited)
    field(:member, :boolean, default: false)
    field(:logo, :string)
    field(:website, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:twitter, :string)
    field(:instagram, :string)
    field(:facebook, :string)
    field(:copy, :string)

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
      :copy
    ])
    |> validate_required([:name])
  end
end
