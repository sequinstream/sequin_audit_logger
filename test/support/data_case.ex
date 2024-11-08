defmodule SequinAuditLogger.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias SequinAuditLogger.Repo

      import Ecto
      import Ecto.Query
      import SequinAuditLogger.DataCase
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(SequinAuditLogger.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
