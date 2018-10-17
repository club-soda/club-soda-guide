defmodule CsGuide.Repo.Migrations.AddVenueVenueTypeLink do
  use Ecto.Migration

  def change do
    create table(:venues_venue_types, primary_key: false) do
      add(:venue_id, references(:venues, on_delete: :delete_all, column: :id, type: :id))

      add(
        :venue_type_id,
        references(:venue_types, on_delete: :delete_all, column: :id, type: :id)
      )
    end
  end
end
