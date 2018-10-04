defmodule CsGuide.Resources.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field(:venue_name, :string)
    field(:postcode, :string)
    field(:phone_number, :string)

    many_to_many(
      :venue_types,
      CsGuide.Categories.VenueType,
      join_through: "venues_venue_types",
      join_keys: [venue_id: :id, venue_type_id: :id]
    )

    many_to_many(
      :drinks,
      CsGuide.Resources.Drink,
      join_through: "venues_drinks",
      join_keys: [venue_id: :id, drink_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:venue_name, :postcode, :phone_number])
    |> validate_required([:venue_name, :postcode])
  end
end
