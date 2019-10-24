defmodule CsGuide.Repo.Migrations.AddVenueDraught do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      add(:draught, :boolean, default: false)
    end
  end
end
