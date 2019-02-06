defmodule CsGuide.DiscountCode do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  @timestamps_opts [type: :naive_datetime_usec]
  schema "discount_codes" do
    field(:code, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    belongs_to(:venue, CsGuide.Resources.Venue)

    timestamps()
  end

  @doc false
  def changeset(discount_code, attrs \\ %{}) do
    discount_code
    |> cast(attrs, [:code, :venue_id])
    |> validate_required([:code])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
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
