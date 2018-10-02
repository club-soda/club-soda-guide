defmodule CsGuide.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add :venue_name, :string
      add :postcode, :string
      add :phone_number, :string

      timestamps()
    end

  end
end
