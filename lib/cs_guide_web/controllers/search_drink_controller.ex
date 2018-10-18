defmodule CsGuideWeb.SearchDrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, %{"drink_type" => type_filter}) do
    drinks =
      Drink.all()
      |> CsGuide.Repo.preload([:drink_types, :brand])
      |> Enum.filter(fn drink ->
        Enum.any?(drink.drink_types, &has_drink_type?/1)
      end)
      |> Enum.filter(fn drink ->
        Enum.any?(drink.drink_types, &matches_d_type_filter?(&1, type_filter))
      end)

    render(conn, "index.html", drinks: drinks)
  end

  defp has_drink_type?(drink_types) do
    drink_types !== []
  end

  defp matches_d_type_filter?(drink_type, type_filter) do
    String.downcase(drink_type.name) == String.downcase(type_filter)
  end

  def index(conn, params) do
    drinks =
      Drink.all()
      |> CsGuide.Repo.preload(:brand)

    render(conn, "index.html", drinks: drinks)
  end
end
