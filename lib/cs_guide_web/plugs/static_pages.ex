defmodule CsGuideWeb.Plugs.StaticPages do
  import Plug.Conn

  alias CsGuide.StaticPage

  @doc false
  def init(default), do: default

  @doc false
  def call(conn, _params) do
    static_page_links =
      StaticPage.all()
      |> Enum.filter(fn p ->
        p.display_in_menu || p.display_in_footer
      end)

    conn
    |> assign(:static_page_links, static_page_links)
  end
end
