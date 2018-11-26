defmodule CsGuide.Resources.Drink do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias CsGuide.Resources

  schema "drinks" do
    field(:name, :string)
    field(:abv, :float)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:description, :string, default: "")
    field(:weighting, :integer)
    field(:ingredients, :string)

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

    has_many(:drink_images, CsGuide.Images.DrinkImage)

    timestamps()
  end

  @doc false
  def changeset(drink, attrs \\ %{}) do
    drink
    |> cast(attrs, [:name, :abv, :brand_id, :description, :weighting, :ingredients])
    |> validate_required([:name])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> Resources.put_belongs_to_assoc(attrs, :brand, :brand_id, CsGuide.Resources.Brand, :name)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :drink_types, CsGuide.Categories.DrinkType, :name)
    |> Resources.put_many_to_many_assoc(
      attrs,
      :drink_styles,
      CsGuide.Categories.DrinkStyle,
      :name
    )
    |> CsGuide.Repo.insert()
  end

  def update(%__MODULE__{} = item, attrs) do
    assocs =
      Enum.map(__MODULE__.__schema__(:associations), fn a ->
        schema = Map.get(__MODULE__.__schema__(:association, a), :queryable)

        selected =
          case Map.get(attrs, to_string(a)) do
            nil -> []
            [_] = selected -> Enum.map(selected, fn {k, v} -> k end)
            selected -> selected
          end

        {a,
         from(s in schema,
           distinct: s.entry_id,
           order_by: [desc: :inserted_at],
           select: s
         )}
      end)

    item
    |> CsGuide.Repo.preload(assocs)
    |> Map.put(:id, nil)
    |> Map.put(:inserted_at, nil)
    |> Map.put(:updated_at, nil)
    |> Resources.put_belongs_to_assoc(attrs, :brand, :brand_id, CsGuide.Resources.Brand, :name)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :drink_types, CsGuide.Categories.DrinkType, :name)
    |> Resources.put_many_to_many_assoc(
      attrs,
      :drink_styles,
      CsGuide.Categories.DrinkStyle,
      :name
    )
    |> CsGuide.Repo.insert()
  end
end
