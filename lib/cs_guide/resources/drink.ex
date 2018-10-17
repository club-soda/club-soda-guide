defmodule CsGuide.Resources.Drink do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  alias CsGuide.Resources

  schema "drinks" do
    field(:abv, :float)
    field(:name, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean)

    many_to_many(
      :venues,
      CsGuide.Resources.Venue,
      join_through: "venues_drinks",
      join_keys: [drink_id: :id, venue_id: :id]
    )

    many_to_many(
      :drink_types,
      CsGuide.Categories.DrinkType,
      join_through: "drink_drink_types",
      join_keys: [drink_id: :id, drink_type_id: :id]
    )

    belongs_to(:brand, CsGuide.Resources.Brand)

    timestamps()
  end

  @doc false
  def changeset(drink, attrs \\ %{}) do
    drink
    |> cast(attrs, [:name, :abv, :brand_id])
    |> validate_required([:name, :abv])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> Resources.put_belongs_to_assoc(attrs, :brand, :brand_id, CsGuide.Resources.Brand, :name)
    |> __MODULE__.changeset(attrs)
    |> CsGuide.Repo.insert()
  end
end
