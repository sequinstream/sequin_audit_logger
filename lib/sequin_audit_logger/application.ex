defmodule SequinAuditLogger.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SequinAuditLogger.Repo,
      {SequinAuditLogger.Pipeline, name: SequinAuditLogger.Pipeline}
    ]

    opts = [strategy: :one_for_one, name: SequinAuditLogger.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
