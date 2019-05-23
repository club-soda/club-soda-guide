defmodule Sitemaps do
  alias CsGuideWeb.{Endpoint, Router.Helpers}

  use Sitemap,
    host: "http://#{Application.get_env(:cs_guide, Endpoint)[:url][:host]}",
    files_path: "priv/static/sitemaps/",
    public_path: "sitemaps/"

  def generate do
    IO.inspect "Hello Rob!"
    create do
      # list each URL that should be included, using your application's routes
      add Helpers.entry_path(Endpoint, :index), priority: 0.5, changefreq: "hourly", expires: nil
      # ...
    end

    # notify search engines (currently Google and Bing) of the updated sitemap
    ping()
  end
end
