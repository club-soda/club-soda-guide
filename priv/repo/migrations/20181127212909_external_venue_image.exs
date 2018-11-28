defmodule CsGuide.Repo.Migrations.ExternalVenueImage do
  use Ecto.Migration

  def change do
    alter table (:venues) do
      add :external_image, :string
    end
  end
end
