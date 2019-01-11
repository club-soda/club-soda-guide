defmodule CsGuide.Repo.Migrations.ChangeBrandCopyToText do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      modify(:copy, :text)
    end
  end
end
