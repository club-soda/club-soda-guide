defmodule CsGuide.Repo.Migrations.LinkVenuesUsers do
  use Ecto.Migration

  def change do
    create table(:venues_users, primary_key: false) do
      add(:venue_id, references(:venues, on_delete: :delete_all, column: :id, type: :id))

      add(:user_id, references(:users, on_delete: :delete_all, column: :id, type: :id))
    end
  end
end
