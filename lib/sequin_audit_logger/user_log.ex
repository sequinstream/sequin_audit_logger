defmodule SequinAuditLogger.UserLog do
  use SequinAuditLogger.Schema
  alias SequinAuditLogger.SequinEvent
  alias __MODULE__

  @primary_key {:sequin_event_id, :string, []}
  schema "user_logs" do
    field :user_id, :string
    field :action, :string
    field :record, :map
    field :changes, :map

    timestamps()
  end

  def from_sequin_event(%SequinEvent{} = event) do
    %UserLog{
      sequin_event_id: event.id,
      user_id: event.record_pk |> to_string(),
      action: event.action,
      record: event.record,
      changes: event.changes
    }
  end
end
