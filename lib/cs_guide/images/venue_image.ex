defmodule CsGuide.Images.VenueImage do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "venue_images" do
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:photo_number, :integer)

    belongs_to(:venue, CsGuide.Resources.Venue)

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:venue_id, :photo_number])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> CsGuide.Resources.add_file_extension(attrs)
    |> CsGuide.Resources.put_belongs_to_assoc(
      attrs,
      :venue,
      :venue_id,
      CsGuide.Resources.Venue,
      :entry_id
    )
    |> __MODULE__.changeset(attrs)
    |> CsGuide.Repo.insert()
  end
end
