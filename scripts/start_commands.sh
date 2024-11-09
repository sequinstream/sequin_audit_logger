#!/bin/bash

# Exit if any command returns a non-zero status.
set -euo pipefail

migrate() {
  echo "Starting migrations"
  ./prod/rel/sequin_audit_logger/bin/sequin_audit_logger eval "SequinAuditLogger.Release.migrate"
  echo 'Migrations complete'
}

start_application() {
  echo "Starting the app"
  PHX_SERVER=true ./prod/rel/sequin_audit_logger/bin/sequin_audit_logger start
}

# Main script execution starts here
echo "Starting: start_commands.sh"

migrate
start_application
