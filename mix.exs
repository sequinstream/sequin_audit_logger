defmodule SequinAuditLogger.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :sequin_audit_logger,
      deps: deps(),
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SequinAuditLogger.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:off_broadway_sequin, github: "sequinstream/off_broadway_sequin"},
      {:ecto, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.10"},
      {:aws_rds_castore, "~> 1.2.0"},
      {:mix_test_interactive, "~> 2.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
