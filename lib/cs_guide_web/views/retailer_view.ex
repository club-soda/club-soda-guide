defmodule CsGuideWeb.RetailerView do
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
end
