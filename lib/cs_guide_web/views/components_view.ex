defmodule CsGuideWeb.ComponentsView do
  use CsGuideWeb, :view

  def generate_venue_url(venue) do
    Enum.join([venue.venue_name, "-", venue.postcode])
    |> change_spaces_to_dashes()
  end

  defp change_spaces_to_dashes(str) do
    str
    |> String.split(" ")
    |> Enum.join("-")
  end
end
