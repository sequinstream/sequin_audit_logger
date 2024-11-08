defmodule SequinAuditLogger.DatabaseLog do
  use SequinAuditLogger.Schema
  alias SequinAuditLogger.SequinEvent
  alias __MODULE__

  @primary_key {:sequin_event_id, :string, []}
  schema "database_logs" do
    field :account_id, :string
    field :database_id, :string
    field :name, :string
    field :action, :string
    field :record, :map
    field :changes, :map

    timestamps()
  end

  def from_sequin_event(%SequinEvent{} = event) do
    %DatabaseLog{
      sequin_event_id: event.id,
      database_id: event.record_pk |> to_string(),
      account_id: event.record["account_id"],
      name: event.record["name"],
      action: event.action,
      record: event.record,
      changes: event.changes
    }
  end
end
