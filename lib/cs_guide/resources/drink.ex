defmodule CsGuide.Resources.Drink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drinks" do
    field(:abv, :float)
    field(:brand, :string)
    field(:name, :string)

    many_to_many(
      :venues,
      CsGuide.Resources.Venue,
      join_through: "venues_drinks",
      join_keys: [drink_id: :id, venue_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(drink, attrs) do
    drink
    |> cast(attrs, [:name, :brand, :abv])
    |> validate_required([:name, :brand, :abv])
  end
end
