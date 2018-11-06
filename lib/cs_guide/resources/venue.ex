defmodule CsGuide.Resources.Venue do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias CsGuide.Repo
  alias CsGuide.Resources

  schema "venues" do
    field(:venue_name, :string)
    field(:postcode, :string)
    field(:phone_number, :string)
    field(:cs_score, :float, default: 0.0)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

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
  def changeset(venue, attrs \\ %{}) do
    venue
    |> cast(attrs, [:venue_name, :postcode, :phone_number, :cs_score])
    |> validate_required([:venue_name])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :name)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :name)
    |> Repo.insert()
  end

  def update(%__MODULE__{} = item, attrs) do
    assocs =
      Enum.map(__MODULE__.__schema__(:associations), fn a ->
        schema = Map.get(__MODULE__.__schema__(:association, a), :queryable)

        selected =
          case Map.get(attrs, to_string(a)) do
            nil -> []
            selected -> Enum.map(selected, fn {k, v} -> k end)
          end

        {a,
         from(s in schema,
           where: s.entry_id in ^selected,
           distinct: s.entry_id,
           order_by: [desc: :inserted_at],
           select: s
         )}
      end)

    item
    |> CsGuide.Repo.preload(assocs)
    |> Map.put(:id, nil)
    |> Map.put(:inserted_at, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :name)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :entry_id)
    |> Repo.insert()
  end
end
