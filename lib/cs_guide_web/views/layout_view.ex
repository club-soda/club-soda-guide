defmodule CsGuideWeb.LayoutView do
  use CsGuideWeb, :view

  def change_spaces_to_dashes(str) do
    str
    |> String.split(" ")
    |> Enum.join("-")
  end
end
