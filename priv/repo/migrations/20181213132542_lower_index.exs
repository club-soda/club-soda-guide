defmodule CsGuide.Repo.Migrations.LowerIndex do
  use Ecto.Migration

  def change do
    create(index("brands", ["(lower(name))"], name: :brands_lower_name_index))
  end
end
