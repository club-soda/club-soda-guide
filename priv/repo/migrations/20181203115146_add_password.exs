defmodule CsGuide.Repo.Migrations.AddPassword do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:password, :binary)
    end
  end
end
