defmodule SequinAuditLogger.Repo.Migrations.CreateAuditTables do
  use Ecto.Migration

  @schema_prefix Application.compile_env!(:sequin_audit_logger, [SequinAuditLogger.Repo, :schema_prefix])

  def change do
    execute "CREATE SCHEMA IF NOT EXISTS #{@schema_prefix}", "select 1"

    create table(:database_logs, primary_key: false, prefix: @schema_prefix) do
      add :sequin_event_id, :string, primary_key: true
      add :account_id, :string, null: false
      add :database_id, :string, null: false
      add :name, :string, null: false
      add :action, :string, null: false
      add :record, :map, null: false
      add :changes, :map, null: true

      timestamps()
    end

    create table(:user_logs, primary_key: false, prefix: @schema_prefix) do
      add :sequin_event_id, :string, primary_key: true
      add :user_id, :string, null: false
      add :action, :string, null: false
      add :record, :map, null: false
      add :changes, :map, null: true

      timestamps()
    end

    create table(:account_logs, primary_key: false, prefix: @schema_prefix) do
      add :sequin_event_id, :string, primary_key: true
      add :account_id, :string, null: false
      add :name, :string, null: false
      add :action, :string, null: false
      add :record, :map, null: false
      add :changes, :map, null: true

      timestamps()
    end

    create table(:consumer_logs, primary_key: false, prefix: @schema_prefix) do
      add :sequin_event_id, :string, primary_key: true
      add :account_id, :string, null: false
      add :name, :string, null: false
      add :kind, :string, null: false
      add :action, :string, null: false
      add :record, :map, null: false
      add :changes, :map, null: true

      timestamps()
    end

    # Add indexes for common query patterns
    create index(:database_logs, [:account_id], prefix: @schema_prefix)
    create index(:user_logs, [:user_id], prefix: @schema_prefix)
    create index(:account_logs, [:account_id], prefix: @schema_prefix)
    create index(:consumer_logs, [:account_id], prefix: @schema_prefix)
  end
end
