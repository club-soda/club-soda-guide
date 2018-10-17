defmodule CsGuide.Repo.Migrations.CreateDrinkTypes do
  use Ecto.Migration

  def change do
    create table(:drink_types) do
      add(:name, :string)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end
  end
end
