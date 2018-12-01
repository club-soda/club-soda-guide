defmodule CsGuideWeb.SearchDrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, _params) do

    render(conn, "index.html")
  end

  defp has_drink_type?(drink_types) do
    drink_types !== []
  end

  defp matches_d_type_filter?(drink_type, type_filter) do
    String.downcase(drink_type.name) == String.downcase(type_filter)
  end

end
