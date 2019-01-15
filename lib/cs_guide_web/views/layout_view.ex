defmodule CsGuideWeb.LayoutView do
  use CsGuideWeb, :view

  def change_spaces_to_dashes(str) do
    String.replace(str, " ", "-")
  end
end
