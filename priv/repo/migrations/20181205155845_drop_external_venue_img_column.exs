defmodule CsGuide.Repo.Migrations.DropExternalVenueImgColumn do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      remove(:external_image)
    end
  end
end
