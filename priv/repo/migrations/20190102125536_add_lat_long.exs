defmodule CsGuide.Repo.Migrations.AddLatLong do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      add(:lat, :float)
      add(:long, :float)
    end
  end
end
