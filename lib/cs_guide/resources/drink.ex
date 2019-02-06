defmodule CsGuide.Resources.Drink do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias CsGuide.Resources

  @timestamps_opts [type: :naive_datetime_usec]
  schema "drinks" do
    field(:name, :string)
    field(:abv, :float)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:description, Fields.DescriptionPlaintextUnlimited, default: "")
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
      join_keys: [drink_id: :id, drink_type_id: :id],
      on_replace: :delete
    )

    many_to_many(
      :drink_styles,
      CsGuide.Categories.DrinkStyle,
      join_through: "drinks_drink_styles",
      join_keys: [drink_id: :id, drink_style_id: :id],
      on_replace: :delete
    )

    has_many(:drink_images, CsGuide.Images.DrinkImage)

    timestamps()
  end

  @doc false
  def changeset(drink, attrs \\ %{}) do
    drink
    |> cast(attrs, [:name, :abv, :brand_id, :description, :weighting, :ingredients])
    |> validate_required([:name, :abv])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> Resources.put_belongs_to_assoc(attrs, :brand, :brand_id, CsGuide.Resources.Brand, :name)
    |> __MODULE__.changeset(attrs)
    |> insert_entry_id()
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
           order_by: [desc: :updated_at],
           select: s
         )}
      end)

    item
    |> CsGuide.Repo.preload(assocs)
    |> Map.put(:id, nil)
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

  def get_drink_card(%__MODULE__{} = drink) do
    %{
      name: drink.name,
      brand: drink.brand.name,
      brandId: drink.brand.entry_id,
      abv: drink.abv,
      drink_types: Enum.map(drink.drink_types, fn t -> t.name end),
      drink_styles: Enum.map(drink.drink_styles, fn t -> t.name end),
      description: drink.description,
      image:
        case List.last(drink.drink_images) do
          nil ->
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyT_ehuzfLvJKLPOAVjobqWtZjFO1--mgpQb_NJmq0wIfpEc5SyXkuPxpG"

          img ->
            "https://s3-eu-west-1.amazonaws.com/#{Application.get_env(:ex_aws, :bucket)}/#{
              img.entry_id
            }"
        end
    }
  end
end
