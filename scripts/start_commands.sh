#!/bin/bash

# Exit if any command returns a non-zero status.
set -euo pipefail

migrate() {
  echo "Starting migrations"
  ./prod/rel/sequin/bin/sequin eval "SequinAuditLogger.Release.migrate"
  echo 'Migrations complete'
}

start_application() {
  echo "Starting the app"
  PHX_SERVER=true ./prod/rel/sequin/bin/sequin start
}

# Main script execution starts here
echo "Starting: start_commands.sh"

migrate
start_application
