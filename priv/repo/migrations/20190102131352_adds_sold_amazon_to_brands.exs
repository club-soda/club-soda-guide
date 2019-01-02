defmodule CsGuide.Repo.Migrations.AddsSoldAmazonToBrands do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      add(:sold_amazon, :boolean, default: false)
    end
  end
end
