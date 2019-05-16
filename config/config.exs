# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cs_guide,
  ecto_repos: [CsGuide.Repo],
  google_maps_api_key: Map.fetch!(System.get_env(), "GOOGLE_MAPS_API_KEY"),
  site_url: System.get_env("SITE_URL")

# Configures the endpoint
config :cs_guide, CsGuideWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: CsGuideWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CsGuide.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :warn

config :ex_aws,
  region: System.get_env("AWS_S3_REGION"),
  bucket: System.get_env("AWS_S3_BUCKET"),
  ex_aws_request: ExAws


config :fields, Fields.AES,
  # get the ENCRYPTION_KEYS env variable
  keys:
    System.get_env("ENCRYPTION_KEYS")
    # remove single-quotes around key list in .env
    |> String.replace("'", "")
    # split the CSV list of keys
    |> String.split(",")
    # decode the key.
    |> Enum.map(fn key -> :base64.decode(key) end)

config :fields, Fields,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :cs_guide, CsGuide.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SES_SERVER"),
  port: System.get_env("SES_PORT"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always,
  ssl: false,
  retries: 1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
