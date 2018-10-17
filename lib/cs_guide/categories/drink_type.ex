defmodule CsGuide.Categories.DrinkType do
  use Ecto.Schema
  use CsGuide.AppendOnly
  import Ecto.Changeset

  schema "drink_types" do
    field(:drink_type, :string)

    many_to_many(
      :drinks,
      CsGuide.Resources.Drinks,
      join_through: "drink_drink_types",
      join_keys: [drink_type_id: :id, drink_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(drink_type, attrs \\ %{}) do
    drink_type
    |> cast(attrs, [:drink_type])
    |> validate_required([:drink_type])
    |> unique_constraint(:drink_type)
  end
end
