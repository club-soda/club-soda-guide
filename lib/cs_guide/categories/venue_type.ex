defmodule CsGuide.Categories.VenueType do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "venue_types" do
    field(:name, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean)

    many_to_many(
      :venues,
      CsGuide.Resources.Venue,
      join_through: "venues_venue_types",
      join_keys: [venue_type_id: :id, venue_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(venue_type, attrs \\ %{}) do
    venue_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
