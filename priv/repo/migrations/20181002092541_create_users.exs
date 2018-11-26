defmodule CsGuide.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :binary)
      add(:email_hash, :binary)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end
  end
end
