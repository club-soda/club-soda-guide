defmodule CsGuideWeb.VenueView do
  use CsGuideWeb, :view
  use Autoform

  import Ecto.Query, only: [from: 2]

  def query(sch) do
    from(s in sch,
      distinct: s.entry_id,
      order_by: [desc: :inserted_at],
      select: s
    )
  end
end
