defmodule SequinAuditLogger.Pipeline do
  use Broadway

  alias Broadway.BatchInfo
  alias SequinAuditLogger.Repo
  alias Broadway.Message
  alias SequinAuditLogger.DatabaseLog
  alias SequinAuditLogger.AccountLog
  alias SequinAuditLogger.ConsumerLog
  alias SequinAuditLogger.UserLog
  alias SequinAuditLogger.SequinEvent

  require Logger

  def start_link(opts) do
    producer = Keyword.get(opts, :producer, OffBroadwaySequin.Producer)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {
          producer,
          consumer_group: Application.get_env(:sequin_audit_logger, :sequin_consumer_group),
          token: Application.get_env(:sequin_audit_logger, :sequin_token),
          base_url: Application.get_env(:sequin_audit_logger, :sequin_base_url)
        }
      ],
      processors: [
        default: [
          concurrency: 5,
          max_demand: 100
        ]
      ],
      batchers: [
        default: [
          batch_size: 100,
          batch_timeout: 1000,
          concurrency: 5
        ]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    event = SequinEvent.from_sequin_message(message.data)

    message
    |> Message.put_data(event)
    |> Message.put_batcher(:default)
    |> Message.put_batch_key(model(event.source_table_name))
  end

  @impl true
  def handle_batch(:default, messages, %BatchInfo{batch_key: model}, _context) do
    events =
      Enum.map(messages, & &1.data)
      |> Enum.map(&model.from_sequin_event/1)
      |> Enum.map(&struct_for_insert/1)

    {count, _} =
      Repo.insert_all(model, events,
        conflict_target: [:sequin_event_id],
        on_conflict: :replace_all
      )

    Logger.info("Inserted #{count} events into #{model}")

    messages
  end

  defp model(table_name) do
    case table_name do
      "postgres_databases" -> DatabaseLog
      "accounts" -> AccountLog
      "http_push_consumers" -> ConsumerLog
      "http_pull_consumers" -> ConsumerLog
      "users" -> UserLog
    end
  end

  defp struct_for_insert(map) do
    map
    |> Map.from_struct()
    |> Map.drop(["__meta__", :__meta__])
    |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))
  end
end
