defmodule CsGuide.Repo.Migrations.CreatesSponsorTable do
  use Ecto.Migration

  def change do
    create table(:sponsor) do
      add(:name, :string)
      add(:body, :text)
      add(:show, :boolean, default: false)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)

      timestamps()
    end
  end
end
