defmodule CsGuide.Repo.Migrations.CreateBrandVenueImages do
  use Ecto.Migration

  def change do
    create table(:brand_images) do
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false, null: false)
      add(:brand_id, references(:brands))
      add(:cover, :boolean)

      timestamps()
    end
  end

  def change do
    create table(:venue_images) do
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false, null: false)
      add(:venue_id, references(:venues))

      timestamps()
    end
  end
end
