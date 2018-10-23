defmodule CsGuide.Categories.DrinkStyle do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "drink_styles" do
    field(:deleted, :boolean, default: false)
    field(:entry_id, :string)
    field(:name, :string)

    many_to_many(
      :drinks,
      CsGuide.Resources.Drink,
      join_through: "drinks_drink_styles",
      join_keys: [drink_type_id: :id, drink_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(drink_style, attrs) do
    drink_style
    |> cast(attrs, [:name, :entry_id, :deleted])
    |> validate_required([:name, :entry_id, :deleted])
  end
end
