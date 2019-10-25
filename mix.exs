defmodule CsGuide.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cs_guide,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CsGuide.Application, []},
      extra_applications: [:logger, :runtime_tools, :ex_aws, :httpoison]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/repo/script_helpers.ex"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:nimble_csv, "~> 0.3"},
      {:autoform, git: "https://github.com/dwyl/autoform.git", tag: "0.6.7"},
      {:alog, git: "https://github.com/dwyl/alog.git", tag: "0.5.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:plug_cowboy, "~> 1.0"},
      {:poison, "~> 1.2", override: true},
      {:httpoison, "~> 0.7"},
      {:fields, git: "https://github.com/dwyl/fields.git", tag: "0.1.7"},
      {:earmark, "~> 1.3.0"},
      {:csv, "~> 2.1"},
      {:bamboo, "~> 1.2"},
      {:bamboo_smtp, "~> 1.7.0"},
      {:ecto_enum, "~> 1.2"},
      {:mime, "~> 1.2"},
      {:sweet_xml, "~> 0.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
