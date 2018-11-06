defmodule CsGuide.Categories.DrinkType do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "drink_types" do
    field(:name, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    many_to_many(
      :drinks,
      CsGuide.Resources.Drink,
      join_through: "drink_drink_types",
      join_keys: [drink_type_id: :id, drink_id: :id]
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
end
