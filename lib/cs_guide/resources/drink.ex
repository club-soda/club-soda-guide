defmodule CsGuide.Resources.Drink do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  alias CsGuide.Resources

  schema "drinks" do
    field(:name, :string)
    field(:abv, :float)
    field(:entry_id, :string)
    field(:deleted, :boolean)
    field(:description, :string)

    belongs_to(:brand, CsGuide.Resources.Brand)

    many_to_many(
      :venues,
      CsGuide.Resources.Venue,
      join_through: "venues_drinks",
      join_keys: [drink_id: :id, venue_id: :id]
    )

    many_to_many(
      :drink_types,
      CsGuide.Categories.DrinkType,
      join_through: "drinks_drink_types",
      join_keys: [drink_id: :id, drink_type_id: :id]
    )

    many_to_many(
      :drink_styles,
      CsGuide.Categories.DrinkStyle,
      join_through: "drinks_drink_styles",
      join_keys: [drink_id: :id, drink_style_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(drink, attrs \\ %{}) do
    drink
    |> cast(attrs, [:name, :abv, :brand_id, :description])
    |> validate_required([:name])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> Resources.put_belongs_to_assoc(attrs, :brand, :brand_id, CsGuide.Resources.Brand, :name)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :drink_types, CsGuide.Categories.DrinkType, :name)
    |> CsGuide.Repo.insert()
  end
end
