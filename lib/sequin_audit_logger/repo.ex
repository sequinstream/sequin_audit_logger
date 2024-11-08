defmodule SequinAuditLogger.Repo do
  use Ecto.Repo,
    otp_app: :sequin_audit_logger,
    adapter: Ecto.Adapters.Postgres
end
