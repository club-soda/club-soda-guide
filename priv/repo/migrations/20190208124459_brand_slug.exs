defmodule CsGuide.Repo.Migrations.BrandSlug do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      add(:slug, :string)
    end
  end
end
