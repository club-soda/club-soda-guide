defmodule CsGuide.Repo.Migrations.AddPhotoNoToVenueImages do
  use Ecto.Migration

  def change do
    alter table(:venue_images) do
      add(:photo_number, :integer, default: 1)
    end
  end
end
