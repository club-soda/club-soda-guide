defmodule CsGuide.Repo.Migrations.TypeStyleLink do
  use Ecto.Migration

  def change do
    create table(:drink_types_drink_styles, primary_key: false) do
      add(
        :drink_type_id,
        references(:drink_types, on_delete: :delete_all, column: :id, type: :id)
      )
      add(
        :drink_style_id,
        references(:drink_styles, on_delete: :delete_all, column: :id, type: :id)
      )
    end
  end
end
