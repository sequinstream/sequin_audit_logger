defmodule SequinAuditLogger.Release do
  @moduledoc false
  @app :sequin_audit_logger

  def migrate(step) do
    load_app()
    ensure_ssl_started()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, step: step))
    end

    :ok
  end

  def migrate do
    load_app()
    ensure_ssl_started()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    [SequinAuditLogger.Repo]
  end

  defp load_app do
    Application.load(@app)
  end

  defp ensure_ssl_started do
    Application.ensure_all_started(:ssl)
  end
end
