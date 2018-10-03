defmodule CsGuide.Repo.Migrations.CreateDrinks do
  use Ecto.Migration

  def change do
    create table(:drinks) do
      add(:name, :string)
      add(:brand, :string)
      add(:abv, :float)

      timestamps()
    end

    create table(:venues_drinks, primary_key: false) do
      add(:venue_id, references(:venues, on_delete: :delete_all, column: :id, type: :id))

      add(:drink_id, references(:drinks, on_delete: :delete_all, column: :id, type: :id))
    end
  end
end
