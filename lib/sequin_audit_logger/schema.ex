defmodule SequinAuditLogger.Schema do
  @moduledoc false
  @type id :: String.t()
  @type t :: Ecto.Schema.t()

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @timestamps_opts [type: :utc_datetime]
      @schema_prefix Application.compile_env!(:sequin_audit_logger, [
                       SequinAuditLogger.Repo,
                       :schema_prefix
                     ])
    end
  end
end
