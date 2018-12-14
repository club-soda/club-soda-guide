defmodule CsGuide.Repo.Migrations.CreateStaticPages do
  use Ecto.Migration

  def change do
    create table(:static_pages) do
      add(:page_title, :string)
      add(:title_in_menu, :string)
      add(:browser_title, :string)
      add(:body, :text)
      add(:display_in_menu, :boolean, default: false)
      add(:display_in_footer, :boolean, default: false)
      add(:entry_id, :string)
      add(:deleted, :boolean, default: false)
      timestamps()
    end
  end
end
