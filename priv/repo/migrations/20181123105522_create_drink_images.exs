defmodule CsGuide.Repo.Migrations.CreateDrinkImages do
  use Ecto.Migration

  def change do
    create table(:drink_images) do
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false, null: false)
      add(:drink_id, references(:drinks))

      timestamps()
    end
  end
end
