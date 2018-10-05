defmodule CsGuide.Resources.Venue do
  use Ecto.Schema
  use CsGuide.AppendOnly
  import Ecto.Changeset

  alias CsGuide.Repo

  schema "venues" do
    field(:venue_name, :string)
    field(:postcode, :string)
    field(:phone_number, :string)
    field(:entry_id, :string)

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
    |> insert_entry_id()
    |> cast(attrs, [:venue_name, :postcode, :phone_number])
    |> validate_required([:venue_name, :postcode])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> venue_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :type)
    |> venue_assoc(attrs, :drinks, CsGuide.Resources.Drink, :name)
    |> Repo.insert()
  end

  def venue_assoc(venue, attrs, assoc, assoc_module, field) do
    assocs =
      Enum.map(Map.get(attrs, to_string(assoc)), fn {f, active} ->
        if String.to_existing_atom(active) do
          Repo.get_by(assoc_module, [{field, f}])
        else
          nil
        end
      end)
      |> Enum.filter(& &1)

    Ecto.Changeset.put_assoc(venue, assoc, assocs)
  end
end
