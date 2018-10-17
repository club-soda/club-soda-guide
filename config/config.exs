# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cs_guide,
  ecto_repos: [CsGuide.Repo]

# Configures the endpoint
config :cs_guide, CsGuideWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4hf8JJmuXBYA1qDB1RpA6wePqW9EHkF6DxqXMshLZcSdTu3yLmoy2OR0Dhq2CYmE",
  render_errors: [view: CsGuideWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CsGuide.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :warn

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
