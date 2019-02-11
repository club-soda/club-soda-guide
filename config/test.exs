use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cs_guide, CsGuideWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
if System.get_env("DATABASE_HOST") do
  config :cs_guide, CsGuide.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "cs_guide_test",
  hostname: System.get_env("DATABASE_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox
else
  config :cs_guide, CsGuide.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "cs_guide_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
end

config :cs_guide,
  ex_aws: CsGuide.Mock.ExAws
