defmodule CsGuide.Repo.Migrations.AddParentCompanyToVenues do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      add(:parent_company, :string, default: "unknown")
    end
  end
end
