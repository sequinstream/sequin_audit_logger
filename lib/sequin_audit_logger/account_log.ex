defmodule SequinAuditLogger.AccountLog do
  use SequinAuditLogger.Schema
  alias SequinAuditLogger.SequinEvent
  alias __MODULE__

  @primary_key {:sequin_event_id, :string, []}
  schema "account_logs" do
    field :account_id, :string
    field :name, :string
    field :action, :string
    field :record, :map
    field :changes, :map

    timestamps()
  end

  def from_sequin_event(%SequinEvent{} = event) do
    %AccountLog{
      sequin_event_id: event.id,
      account_id: event.record_pk |> to_string(),
      name: event.record["name"],
      action: event.action,
      record: event.record,
      changes: event.changes
    }
  end
end
