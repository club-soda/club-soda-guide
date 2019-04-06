defmodule CsGuide.Repo.Migrations.AddSoldOcadoToBrands do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      add(:sold_ocado, :boolean, default: false)
    end
  end
end
