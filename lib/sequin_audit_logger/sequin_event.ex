defmodule SequinAuditLogger.SequinEvent do
  alias OffBroadwaySequin.SequinClient.MessageData

  defstruct [
    :id,
    :seq,
    :source_database_id,
    :source_table_oid,
    :source_table_schema,
    :source_table_name,
    :action,
    :record_pk,
    :record,
    :changes,
    :committed_at,
    :inserted_at
  ]

  def from_sequin_message(%MessageData{} = message_data) do
    map = message_data.data
    {:ok, committed_at, _} = DateTime.from_iso8601(map["committed_at"])
    {:ok, inserted_at, _} = DateTime.from_iso8601(map["inserted_at"])

    %__MODULE__{
      id: map["id"] |> to_string(),
      seq: map["seq"],
      source_database_id: map["source_database_id"],
      source_table_oid: map["source_table_oid"],
      source_table_schema: map["source_table_schema"],
      source_table_name: map["source_table_name"],
      action: map["action"],
      record_pk: map["record_pk"],
      record: map["record"],
      changes: map["changes"],
      committed_at: committed_at,
      inserted_at: inserted_at
    }
  end
end
