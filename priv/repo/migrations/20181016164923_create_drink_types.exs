defmodule CsGuide.Repo.Migrations.CreateDrinkTypes do
  use Ecto.Migration

  def change do
    create table(:drink_types) do
      add(:name, :string)

      timestamps()
    end
  end
end
