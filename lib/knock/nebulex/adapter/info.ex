defmodule Knock.Nebulex.Adapter.Info do
  @moduledoc """
  Specifies the adapter Info API.

  See `Knock.Nebulex.Adapters.Common.Info`.
  """

  @doc """
  Returns `{:ok, info}` where `info` contains the requested cache information,
  as specified by the `spec`.

  If there's an error with executing the command, `{:error, reason}`
  is returned, where `reason` is the cause of the error.

  The `spec` (information specification key) can be:

    * **The atom `:all`**: returns a map with all information items.
    * **An atom**: returns the value for the requested information item.
    * **A list of atoms**: returns a map only with the requested information
      items.

  The adapters are free to add the information specification keys they want,
  however, Nebulex suggests the adapters add the following specs:

    * `:server` - General information about the cache server (e.g., cache name,
      adapter, PID, etc.).
    * `:memory` - Memory consumption information (e.g., used memory,
      allocated memory, etc.).
    * `:stats` - Cache statistics (e.g., hits, misses, etc.).

  See `c:Knock.Nebulex.Cache.info/2`.
  """
  @callback info(
              Knock.Nebulex.Adapter.adapter_meta(),
              Knock.Nebulex.Cache.info_spec(),
              Knock.Nebulex.Cache.opts()
            ) :: Knock.Nebulex.Cache.ok_error_tuple(Knock.Nebulex.Cache.info_data())
end
