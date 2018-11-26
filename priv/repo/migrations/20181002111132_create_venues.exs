defmodule CsGuide.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add(:venue_name, :string)
      add(:description, :text)
      add(:postcode, :string)
      add(:address, :string)
      add(:city, :string)
      add(:website, :string)
      add(:phone_number, :string)
      add(:cs_score, :float, default: 0)
      add(:favourite, :boolean, default: false)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)
      add(:num_cocktails, :integer)
      add(:facebook, :string)
      add(:instagram, :string)
      add(:twitter, :string)

      timestamps()
    end
  end
end
