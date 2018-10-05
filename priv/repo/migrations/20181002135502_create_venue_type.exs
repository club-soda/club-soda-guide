defmodule CsGuide.Repo.Migrations.CreateVenueType do
  use Ecto.Migration

  def change do
    create table(:venue_types) do
      add(:type, :string)
      add(:entry_id, :string)

      timestamps()
    end
  end
end
