defmodule SequinAuditLogger.PipelineTest do
  use SequinAuditLogger.DataCase

  alias SequinAuditLogger.{
    Pipeline,
    Repo,
    UserLog,
    AccountLog,
    ConsumerLog,
    DatabaseLog
  }

  @moduletag :capture_log

  setup do
    # Start Broadway with DummyProducer for testing
    {:ok, _pid} = Pipeline.start_link(producer: Broadway.DummyProducer)

    %{pipeline: Pipeline}
  end

  describe "user events" do
    test "processes user creation events", %{pipeline: pipeline} do
      user_event = %{
        "id" => "evt_123",
        "seq" => 1,
        "source_database_id" => "db_1",
        "source_table_oid" => 12345,
        "source_table_schema" => "public",
        "source_table_name" => "users",
        "action" => "insert",
        "record_pk" => "user_1",
        "record" => %{
          "user_id" => "user_1",
          "email" => "test@example.com"
        },
        "changes" => %{
          "email" => "test@example.com"
        },
        "committed_at" => "2024-03-20T12:00:00Z",
        "inserted_at" => "2024-03-20T12:00:00Z"
      }

      ref = Broadway.test_message(pipeline, user_event)

      assert_receive {:ack, ^ref, [_successful], []}, 1000

      # Verify database state
      assert [user_log] = Repo.all(UserLog)
      assert user_log.user_id == "user_1"
      assert user_log.action == "insert"
      assert user_log.sequin_event_id == "evt_123"
      assert user_log.record == %{"user_id" => "user_1", "email" => "test@example.com"}
      assert user_log.changes == %{"email" => "test@example.com"}
    end
  end

  describe "account events" do
    test "processes account update events", %{pipeline: pipeline} do
      account_event = %{
        "id" => "evt_456",
        "seq" => 2,
        "source_database_id" => "db_1",
        "source_table_oid" => 12346,
        "source_table_schema" => "public",
        "source_table_name" => "accounts",
        "action" => "update",
        "record_pk" => "acc_1",
        "record" => %{
          "account_id" => "acc_1",
          "name" => "Updated Account"
        },
        "changes" => %{
          "name" => "Updated Account"
        },
        "committed_at" => "2024-03-20T12:00:00Z",
        "inserted_at" => "2024-03-20T12:00:00Z"
      }

      ref = Broadway.test_message(pipeline, account_event)

      assert_receive {:ack, ^ref, [_successful], []}, 1000

      assert [account_log] = Repo.all(AccountLog)
      assert account_log.account_id == "acc_1"
      assert account_log.name == "Updated Account"
      assert account_log.action == "update"
      assert account_log.sequin_event_id == "evt_456"
    end
  end

  describe "consumer events" do
    test "processes http_push_consumer events", %{pipeline: pipeline} do
      consumer_event = %{
        "id" => "evt_789",
        "seq" => 3,
        "source_database_id" => "db_1",
        "source_table_oid" => 12347,
        "source_table_schema" => "public",
        "source_table_name" => "http_push_consumers",
        "action" => "insert",
        "record_pk" => "consumer_1",
        "record" => %{
          "account_id" => "acc_1",
          "name" => "New Consumer",
          "kind" => "push"
        },
        "changes" => %{
          "name" => "New Consumer"
        },
        "committed_at" => "2024-03-20T12:00:00Z",
        "inserted_at" => "2024-03-20T12:00:00Z"
      }

      ref = Broadway.test_message(pipeline, consumer_event)

      assert_receive {:ack, ^ref, [_successful], []}, 1000

      assert [consumer_log] = Repo.all(ConsumerLog)
      assert consumer_log.account_id == "acc_1"
      assert consumer_log.name == "New Consumer"
      assert consumer_log.kind == "push"
      assert consumer_log.action == "insert"
      assert consumer_log.sequin_event_id == "evt_789"
    end

    test "processes http_pull_consumer events", %{pipeline: pipeline} do
      consumer_event = %{
        "id" => "evt_101",
        "seq" => 4,
        "source_database_id" => "db_1",
        "source_table_oid" => 12348,
        "source_table_schema" => "public",
        "source_table_name" => "http_pull_consumers",
        "action" => "insert",
        "record_pk" => "consumer_2",
        "record" => %{
          "account_id" => "acc_1",
          "name" => "Pull Consumer",
          "kind" => "pull"
        },
        "changes" => %{
          "name" => "Pull Consumer"
        },
        "committed_at" => "2024-03-20T12:00:00Z",
        "inserted_at" => "2024-03-20T12:00:00Z"
      }

      ref = Broadway.test_message(pipeline, consumer_event)

      assert_receive {:ack, ^ref, [_successful], []}, 1000

      assert [consumer_log] = Repo.all(ConsumerLog)
      assert consumer_log.account_id == "acc_1"
      assert consumer_log.name == "Pull Consumer"
      assert consumer_log.kind == "pull"
      assert consumer_log.action == "insert"
      assert consumer_log.sequin_event_id == "evt_101"
    end
  end

  describe "database events" do
    test "processes postgres_databases events", %{pipeline: pipeline} do
      database_event = %{
        "id" => "evt_202",
        "seq" => 5,
        "source_database_id" => "db_1",
        "source_table_oid" => 12349,
        "source_table_schema" => "public",
        "source_table_name" => "postgres_databases",
        "action" => "insert",
        "record_pk" => "db_1",
        "record" => %{
          "account_id" => "acc_1",
          "name" => "Production DB"
        },
        "changes" => %{
          "name" => "Production DB"
        },
        "committed_at" => "2024-03-20T12:00:00Z",
        "inserted_at" => "2024-03-20T12:00:00Z"
      }

      ref = Broadway.test_message(pipeline, database_event)

      assert_receive {:ack, ^ref, [_successful], []}, 1000

      assert [database_log] = Repo.all(DatabaseLog)
      assert database_log.account_id == "acc_1"
      assert database_log.name == "Production DB"
      assert database_log.action == "insert"
      assert database_log.sequin_event_id == "evt_202"
    end
  end

  describe "batch processing" do
    test "processes multiple events in a batch", %{pipeline: pipeline} do
      events = [
        %{
          "id" => "evt_301",
          "source_table_name" => "users",
          "action" => "insert",
          "record" => %{"user_id" => "user_1"},
          "changes" => %{},
          "committed_at" => "2024-03-20T12:00:00Z",
          "inserted_at" => "2024-03-20T12:00:00Z"
        },
        %{
          "id" => "evt_302",
          "source_table_name" => "users",
          "action" => "update",
          "record" => %{"user_id" => "user_2"},
          "changes" => %{},
          "committed_at" => "2024-03-20T12:00:00Z",
          "inserted_at" => "2024-03-20T12:00:00Z"
        }
      ]

      ref = Broadway.test_batch(pipeline, events, batch_mode: :flush)

      assert_receive {:ack, ^ref, [_, _], []}, 1000

      user_logs = Repo.all(UserLog)
      assert length(user_logs) == 2

      assert Enum.map(user_logs, & &1.sequin_event_id) |> Enum.sort() == ["evt_301", "evt_302"]
      assert Enum.map(user_logs, & &1.action) |> Enum.sort() == ["insert", "update"]
    end
  end

  describe "error handling" do
    test "handles invalid event gracefully", %{pipeline: pipeline} do
      invalid_event = %{
        "id" => "evt_999",
        "source_table_name" => "unknown_table",
        "action" => "insert",
        "record" => %{},
        "changes" => %{},
        "committed_at" => "2024-03-20T12:00:00Z",
        "inserted_at" => "2024-03-20T12:00:00Z"
      }

      ref = Broadway.test_message(pipeline, invalid_event)

      # The message should be acknowledged but marked as failed
      assert_receive {:ack, ^ref, [], [failed]}, 1000
      assert failed.data["id"] == "evt_999"
    end
  end
end
