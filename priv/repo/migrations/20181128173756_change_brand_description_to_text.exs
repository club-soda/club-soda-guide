defmodule CsGuide.Repo.Migrations.ChangeBrandDescriptionToText do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      modify(:description, :text)
    end
  end
end
