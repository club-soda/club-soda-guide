defmodule CsGuide.Categories.DrinkType do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset
  alias CsGuide.Resources
  alias CsGuide.Repo

  schema "drink_types" do
    field(:name, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    many_to_many(
      :drinks,
      CsGuide.Resources.Drink,
      join_through: "drinks_drink_types",
      join_keys: [drink_type_id: :id, drink_id: :id]
    )

    many_to_many(
      :drink_styles,
      CsGuide.Categories.DrinkStyle,
      join_through: "drink_types_drink_styles",
      join_keys: [drink_type_id: :id, drink_style_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(drink_type, attrs \\ %{}) do
    drink_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def insert(attrs) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> insert_entry_id()
    |> Repo.insert()
  end

  def update(%__MODULE__{} = item, attrs) do
    item
    |> __MODULE__.preload(__MODULE__.__schema__(:associations))
    |> Map.put(:id, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
  end
end
