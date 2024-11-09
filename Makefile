.PHONY: dev deviex buildpush

dev: ## Run the app locally
	elixir --sname sequin-audit-logger-dev --cookie sequin-audit-logger-dev -S mix phx.server

deviex: ## Open an IEx session on the running local app
	iex --sname console-$$(openssl rand -hex 4) --remsh sequin-audit-logger-dev --cookie sequin-audit-logger-dev

buildpush:
	mix buildpush

%:
	@:
