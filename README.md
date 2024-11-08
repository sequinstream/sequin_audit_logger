# SequinAuditLogger

A pipeline that logs Postgres events from [Sequin Cloud](https://sequinstream.com) to a Postgres database. This project demonstrates how to build a robust audit logging system using [Sequin](https://github.com/sequinstream/sequin)'s change data capture (CDC) capabilities.

## Overview

SequinAuditLogger subscribes to database changes from Sequin Cloud and maintains a complete audit trail of modifications to key tables in our database.

Each change is captured with:

- The event ID and action (insert/update/delete)
- Full record state at time of change
- Specific fields that were modified
- Timestamps for when the change occurred

## How It Works

1. The pipeline subscribes to a Sequin Consumer Group, which is receiving events from Sequin's prod db
2. Each database change is received as a message and transformed into a SequinEvent
3. Events are batched by table type and bulk inserted into corresponding audit log tables

## Project Structure

### Core Components

- `Pipeline` (`lib/pipeline.ex`) - The main Broadway pipeline that processes events
- `SequinEvent` (`lib/sequin_event.ex`) - Structures raw CDC messages into normalized events
- Log Models - Handle persistence for each type of audit log:
  - `DatabaseLog`
  - `AccountLog`
  - `UserLog`
  - `ConsumerLog`

### Key Files

- `mix.exs` - Project configuration and dependencies
- `priv/repo/migrations/` - Database schema definitions
- `lib/sequin_audit_logger/`
  - `application.ex` - Application supervision tree
  - `pipeline.ex` - Main event processing pipeline
  - Various `*_log.ex` files - Audit log models

## Getting Started

1. Configure environment variables:

```elixir
config :sequin_audit_logger,
  sequin_token: "your_token",
  sequin_consumer_group: "audit_logger",
  sequin_base_url: "https://api.sequinstream.com"
```

2. Setup the database:

```bash
mix ecto.setup
```

3. Start the application:

```bash
mix run --no-halt
```
