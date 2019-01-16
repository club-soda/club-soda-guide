defmodule CsGuide.Repo.Migrations.CreatesDiscountCodes do
  use Ecto.Migration

  def change do
    create table(:discount_codes) do
      add(:code, :string, default: "CLUBSODAVIP")
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)
      add(:venue_id, references(:venues))

      timestamps()
    end
  end
end
