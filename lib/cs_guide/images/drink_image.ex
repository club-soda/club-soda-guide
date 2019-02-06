defmodule CsGuide.Images.DrinkImage do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "drink_images" do
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    belongs_to(:drink, CsGuide.Resources.Drink)

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:drink_id])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> CsGuide.Resources.put_belongs_to_assoc(
      attrs,
      :drink,
      :drink_id,
      CsGuide.Resources.Drink,
      :entry_id
    )
    |> __MODULE__.changeset(attrs)
    |> CsGuide.Repo.insert()
  end
end
