import Config

config :sequin_audit_logger, SequinAuditLogger.Repo, pool_size: 20

config :sequin_audit_logger,
  sequin_base_url: "https://api.sequinstream.com/",
  sequin_consumer_group: "sequin_prod_audit_logger"
