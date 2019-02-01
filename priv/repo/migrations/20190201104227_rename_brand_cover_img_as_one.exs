defmodule CsGuide.Repo.Migrations.RenameBrandCoverImgAsOne do
  use Ecto.Migration

  def change do
    rename(table(:brand_images), :cover, to: :one)
  end
end
