defmodule CsGuide.Repo.Migrations.CreateDrinkStyles do
  use Ecto.Migration

  def change do
    create table(:drink_styles) do
      add(:name, :string)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false, null: false)

      timestamps()
    end

    create table(:drinks_drink_styles, primary_key: false) do
      add(:drink_id, references(:drinks, on_delete: :delete_all, column: :id, type: :id))

      add(
        :drink_style_id,
        references(:drink_styles, on_delete: :delete_all, column: :id, type: :id)
      )
    end
  end
end
