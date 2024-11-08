import Config

config :sequin_audit_logger, SequinAuditLogger.Repo,
  database: "audit_logger",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  schema_prefix: "sequin_audit"

config :sequin_audit_logger,
  ecto_repos: [SequinAuditLogger.Repo]

import_config "#{config_env()}.exs"
