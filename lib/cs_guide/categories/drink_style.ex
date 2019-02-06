defmodule CsGuide.Categories.DrinkStyle do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset
  alias CsGuide.Resources
  alias CsGuide.Repo

  @timestamps_opts [type: :naive_datetime_usec]
  schema "drink_styles" do
    field(:deleted, :boolean, default: false)
    field(:entry_id, :string)
    field(:name, :string)

    many_to_many(
      :drinks,
      CsGuide.Resources.Drink,
      join_through: "drinks_drink_styles",
      join_keys: [drink_style_id: :id, drink_id: :id]
    )

    many_to_many(
      :drink_types,
      CsGuide.Categories.DrinkType,
      join_through: "drink_types_drink_styles",
      join_keys: [drink_style_id: :id, drink_type_id: :id],
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(drink_style, attrs \\ %{}) do
    drink_style
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> insert_entry_id()
    |> Resources.put_many_to_many_assoc(attrs, :drink_types, CsGuide.Categories.DrinkType, :name)
    |> Repo.insert()
  end

  def update(%__MODULE__{} = item, attrs) do
    item
    |> __MODULE__.preload(__MODULE__.__schema__(:associations))
    |> Map.put(:id, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :drink_types, CsGuide.Categories.DrinkType, :name)
    |> Repo.insert()
  end
end
