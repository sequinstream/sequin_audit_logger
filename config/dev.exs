import Config

config :sequin_audit_logger, SequinAuditLogger.Repo,
  database: "audit_logger",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432

config :sequin_audit_logger,
  ecto_repos: [SequinAuditLogger.Repo],
  sequin_consumer_group: "sequin_dev_audit_logger",
  sequin_base_url: "http://localhost:4000"

if "dev.secret.exs" |> Path.expand(__DIR__) |> File.exists?() do
  import_config "dev.secret.exs"
end
