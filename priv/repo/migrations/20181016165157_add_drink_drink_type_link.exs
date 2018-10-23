defmodule CsGuide.Repo.Migrations.AddDrinksDrinkTypeLink do
  use Ecto.Migration

  def change do
    create table(:drinks_drink_types, primary_key: false) do
      add(:drink_id, references(:drinks, on_delete: :delete_all, column: :id, type: :id))

      add(
        :drink_type_id,
        references(:drink_types, on_delete: :delete_all, column: :id, type: :id)
      )
    end
  end
end
