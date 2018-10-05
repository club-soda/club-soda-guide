defmodule CsGuide.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:entry_id, :string)

      timestamps()
    end
  end
end
