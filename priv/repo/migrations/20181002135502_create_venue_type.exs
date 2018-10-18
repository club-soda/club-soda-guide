defmodule CsGuide.Repo.Migrations.CreateVenueType do
  use Ecto.Migration

  def change do
    create table(:venue_types) do
      add(:name, :string)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end
  end
end
