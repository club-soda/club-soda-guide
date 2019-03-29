defmodule CsGuide.Repo.Migrations.SearchLog do
  use Ecto.Migration

  def change do
    create table(:search_log) do
      add(:search, :string)
      timestamps()
    end
  end
end
