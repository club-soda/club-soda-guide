defmodule CsGuide.Repo.Migrations.AddEarthDistance do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS cube")
    execute("CREATE EXTENSION IF NOT EXISTS earthdistance")
    execute("CREATE INDEX location_index ON venues USING gist (ll_to_earth(lat, long));")
  end
end
