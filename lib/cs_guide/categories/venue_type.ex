defmodule CsGuide.Categories.VenueType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venue_types" do
    field(:type, :string)

    many_to_many(
      :venues,
      CsGuide.Resources.Venue,
      join_through: "venues_venue_types",
      join_keys: [venue_type_id: :id, venue_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(venue_type, attrs) do
    venue_type
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> unique_constraint(:type)
  end
end
