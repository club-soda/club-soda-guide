defmodule CsGuide.Repo.Migrations.CreateDrinks do
  use Ecto.Migration

  def change do
    create table(:brands) do
      add(:name, :string)
      add(:member, :boolean, default: false, null: false)
      add(:description, :string)
      add(:logo, :string)
      add(:website, :string)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end

    create table(:drinks) do
      add(:name, :string)
      add(:brand_id, references(:brands))
      add(:abv, :float)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end

    create table(:venues_drinks, primary_key: false) do
      add(:venue_id, references(:venues, on_delete: :delete_all, column: :id, type: :id))

      add(:drink_id, references(:drinks, on_delete: :delete_all, column: :id, type: :id))
    end
  end
end
