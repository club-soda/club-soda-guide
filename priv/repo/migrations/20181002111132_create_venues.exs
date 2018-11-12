defmodule CsGuide.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add(:venue_name, :string)
      add(:description, :text)
      add(:address1, :string)
      add(:address2, :string)
      add(:postcode, :string)
      add(:website, :string)
      add(:phone_number, :string)
      add(:facebook, :string)
      add(:instagram, :string)
      add(:cs_score, :float, default: 0)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end
  end
end
