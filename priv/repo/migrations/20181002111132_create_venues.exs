defmodule CsGuide.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add(:venue_name, :string)
      add(:postcode, :string)
      add(:phone_number, :string)
      add(:cs_score, :float, default: 0)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end
  end
end
