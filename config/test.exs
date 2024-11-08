import Config

config :sequin_audit_logger, SequinAuditLogger.Repo,
  database: "audit_logger_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  schema_prefix: "sequin_audit",
  pool: Ecto.Adapters.SQL.Sandbox
