defmodule CsGuide.Venue do
  use Ecto.Schema
  import Ecto.Changeset


  schema "venues" do
    field :phone_number, :string
    field :postcode, :string
    field :venue_name, :string

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:venue_name, :postcode, :phone_number])
    |> validate_required([:venue_name, :postcode, :phone_number])
  end
end
