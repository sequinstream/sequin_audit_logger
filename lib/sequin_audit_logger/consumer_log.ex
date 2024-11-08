defmodule SequinAuditLogger.ConsumerLog do
  use SequinAuditLogger.Schema
  alias SequinAuditLogger.SequinEvent
  alias __MODULE__

  @primary_key {:sequin_event_id, :string, []}
  schema "consumer_logs" do
    field :account_id, :string
    field :name, :string
    field :kind, :string
    field :action, :string
    field :record, :map
    field :changes, :map

    timestamps()
  end

  def from_sequin_event(%SequinEvent{} = event) do
    dbg(event)

    kind =
      if event.source_table_name == "http_pull_consumers",
        do: "http_pull_consumer",
        else: "http_push_consumer"

    %ConsumerLog{
      sequin_event_id: event.id,
      account_id: event.record["account_id"],
      name: event.record["name"],
      kind: kind,
      action: event.action,
      record: event.record,
      changes: event.changes
    }
  end
end
