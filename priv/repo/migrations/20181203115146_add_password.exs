defmodule CsGuide.Repo.Migrations.AddPassword do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:password, :binary)
      add(:admin, :boolean, default: false)
    end
  end
end
