defmodule CsGuideWeb.VenueView do
  use CsGuideWeb, :view
  use Autoform

  import Ecto.Query, only: [from: 2, subquery: 1]

  def query(sch) do
    sub =
      from(s in sch,
        distinct: s.entry_id,
        order_by: [desc: :inserted_at],
        select: s
      )

    from(m in subquery(sub), where: not m.deleted, select: m)
  end

  def under_map_link(conn, key, str) do
    venue = conn.assigns.venue
    render("link_under_map.html", conn: conn, venue: venue, link_key: key, img_str: str)
  end
end
