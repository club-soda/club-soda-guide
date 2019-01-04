defmodule CsGuide.Repo.Migrations.AddsRetailerSitesToBrands do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      add(:sold_aldi, :boolean, default: false)
      add(:sold_amazon, :boolean, default: false)
      add(:sold_asda, :boolean, default: false)
      add(:sold_dd, :boolean, default: false)
      add(:sold_morrisons, :boolean, default: false)
      add(:sold_sainsburys, :boolean, default: false)
      add(:sold_tesco, :boolean, default: false)
      add(:sold_waitrose, :boolean, default: false)
      add(:sold_wb, :boolean, default: false)
    end
  end
end
