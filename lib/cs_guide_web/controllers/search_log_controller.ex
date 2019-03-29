defmodule CsGuideWeb.SearchLogController do
  use CsGuideWeb, :controller

  alias CsGuide.{Repo, SearchLog}
  import Ecto.Query

  def index(conn, _params) do
    searches_log = SearchLog |> order_by(desc: :inserted_at) |> Repo.all()
    render(conn, "index.html", searches_log: searches_log)
  end

end
