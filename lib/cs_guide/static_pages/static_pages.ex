defmodule CsGuide.StaticPage do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "static_pages" do
    field(:page_title, :string)
    field(:title_in_menu, :string)
    field(:browser_title, :string)
    field(:body, :string)
    field(:display_in_menu, :boolean, default: false)
    field(:display_in_footer, :boolean, default: false)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(static_page, attrs \\ %{}) do
    static_page
    |> cast(attrs, [
      :page_title,
      :title_in_menu,
      :browser_title,
      :body,
      :display_in_menu,
      :display_in_footer
    ])
    |> validate_required([:page_title, :body])
  end
end
