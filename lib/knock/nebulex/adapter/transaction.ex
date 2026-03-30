defmodule Knock.Nebulex.Adapter.Transaction do
  @moduledoc """
  Specifies the adapter Transaction API.
  """

  @doc """
  Runs the given function inside a transaction.

  If an Elixir exception occurs, the exception will bubble up from the
  transaction function. If the cache aborts the transaction, it returns
  `{:error, reason}`.

  A successful transaction returns the value returned by the function wrapped
  in a tuple as `{:ok, value}`.

  See `c:Knock.Nebulex.Cache.transaction/2`.
  """
  @callback transaction(Knock.Nebulex.Adapter.adapter_meta(), fun(), Knock.Nebulex.Cache.opts()) ::
              Knock.Nebulex.Cache.ok_error_tuple(any())

  @doc """
  Returns `{:ok, true}` if the current process is inside a transaction;
  otherwise, `{:ok, false}` is returned.

  If there's an error with executing the command, `{:error, reason}`
  is returned, where `reason` is the cause of the error.

  See `c:Knock.Nebulex.Cache.in_transaction?/1`.
  """
  @callback in_transaction?(Knock.Nebulex.Adapter.adapter_meta(), Knock.Nebulex.Cache.opts()) ::
              Knock.Nebulex.Cache.ok_error_tuple(boolean())
end
