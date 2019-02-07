defmodule CsGuideWeb.ComponentsView do
  use CsGuideWeb, :view

  def url_brand_name(name) do
    name
    |> String.split("-") |> Enum.join("_")
    |> String.split(" ") |> Enum.join("-")
  end
end
