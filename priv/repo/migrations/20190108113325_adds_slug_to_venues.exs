defmodule CsGuide.Repo.Migrations.AddsSlugToVenues do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      add(:slug, :string)
    end
  end
end
