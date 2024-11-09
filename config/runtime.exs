import Config

if config_env() == :prod do
  config :sequin_audit_logger,
    sequin_token: System.fetch_env!("SEQUIN_TOKEN")

  config :sequin_audit_logger, SequinAuditLogger.Repo,
    url: System.fetch_env!("PG_URL"),
    ssl: AwsRdsCAStore.ssl_opts(System.fetch_env!("PG_URL"))
end
