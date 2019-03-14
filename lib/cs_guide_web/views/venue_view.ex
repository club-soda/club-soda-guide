defmodule CsGuideWeb.VenueView do
  use CsGuideWeb, :view
  use Autoform

  import Ecto.Query, only: [from: 2, subquery: 1]

  def query(sch) do
    sub =
      from(s in sch,
        distinct: s.entry_id,
        order_by: [desc: :updated_at],
        select: s
      )

    from(m in subquery(sub), where: not m.deleted, select: m)
  end

  def under_map_link(conn, key, str, is_authenticated) do
    venue = conn.assigns.venue

    render("link_under_map.html",
      conn: conn,
      venue: venue,
      link_key: key,
      img_str: str,
      is_authenticated: is_authenticated
    )
  end

  def create_google_search_url(params) do
    list = [
      Map.get(params, :venue_name),
      Map.get(params, :address),
      Map.get(params, :city),
      Map.get(params, :postcode)
    ]

    query_str =
      list
      |> Enum.reduce([], &if(&1 == nil, do: &2, else: [format_str(&1) | &2]))
      |> Enum.join("%2C+")

    "https://www.google.com/maps/search/?api=1&query=" <> query_str
  end

  def background_colour_type(type_name) do
    values = %{
      "Bars" => "bg-cs-mint ",
      "Pubs" => "bg-cs-yellow",
      "Restaurants" => "bg-cs-light-pink",
      "Cafes" => "bg-cs-navy white",
      "Hotels" => "bg-cs-mid-blue white"
    }

    values[type_name] || "bg-cs-black white"
  end

  def add_line_breaks(str) do
    String.replace(str, ~r{\r\n|\n|\r}, "<br/>")
  end

  defp format_str(str) do
    str
    |> String.split(" ")
    |> Enum.join("+")
  end

  def order_drinks_by_type(drinks) do
    drinks
    |> Enum.sort_by(& &1.drink_types)
  end
end
