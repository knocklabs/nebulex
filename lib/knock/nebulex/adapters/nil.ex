defmodule Knock.Nebulex.Adapters.Nil do
  @moduledoc """
  The Nil adapter is a special cache adapter that turns off the cache. It loses
  all the items saved on it and returns nil for all read operations and true for
  all save operations. This adapter is mostly useful for tests.

  ## Shared options

  All of the cache functions accept the following options
  when using this adapter:

  #{Knock.Nebulex.Adapters.Nil.Options.runtime_shared_options_docs()}

  ## Example

  Suppose you have an application using Ecto for database access and Nebulex
  for caching. Then, you have defined a cache and a repo within it. Since you
  are using a database, there might be some cases where you may want to turn
  off the cache to avoid issues when running the test. For example, in some
  test cases, when accessing the database, you expect no data, but you can
  still get unexpected data since the cache is not flushed. Therefore, you
  must delete all entries from the cache before running each test to ensure
  the cache is always empty. Here is where the Nil adapter comes in, instead
  of adding code to flush the cache before each test, you could define a test
  cache using the Nil adapter for the tests.

  On one hand, you have defined the cache in your application within
  `lib/my_app/cache.ex`:

      defmodule MyApp.Cache do
        use Knock.Nebulex.Cache,
          otp_app: :my_app,
          adapter: Knock.Nebulex.Adapters.Local
      end

  On the other hand, in the tests, you have defined the test cache within
  `test/support/test_cache.ex`:

      defmodule MyApp.TestCache do
        use Knock.Nebulex.Cache,
          otp_app: :my_app,
          adapter: Knock.Nebulex.Adapters.Nil
      end

  You must tell the app what cache to use depending on the environment. For
  tests, you configure `MyApp.TestCache`; otherwise, it is always `MyApp.Cache`.
  You can do this by introducing a new config parameter to decide which cache
  module to use. For tests, you can define the config `config/test.exs`:

      config :my_app,
        nebulex_cache: MyApp.TestCache,
        ...

  The final piece is to read the config parameter and start the cache properly.
  Within `lib/my_app/application.ex`, you could have:

      def start(_type, _args) do
        children = [
          {Application.get_env(:my_app, :nebulex_cache, MyApp.Cache), []},
        ]

        ...

  As you may notice, `MyApp.Cache` is used by default unless the
  `:nebulex_cache` option points to a different module, which will
  be when tests are executed (`test` env).
  """

  # Provide Cache Implementation
  @behaviour Knock.Nebulex.Adapter
  @behaviour Knock.Nebulex.Adapter.KV
  @behaviour Knock.Nebulex.Adapter.Queryable
  @behaviour Knock.Nebulex.Adapter.Transaction

  # Inherit default info implementation
  use Knock.Nebulex.Adapters.Common.Info

  # Inherit default observable implementation
  use Knock.Nebulex.Adapter.Observable

  import Knock.Nebulex.Utils, only: [wrap_error: 2]

  alias __MODULE__.Options
  alias Knock.Nebulex.Adapters.Common.Info.Stats

  ## Knock.Nebulex.Adapter

  @impl true
  defmacro __before_compile__(_env), do: :ok

  @impl true
  def init(opts) do
    telemetry_prefix = Keyword.fetch!(opts, :telemetry_prefix)

    child_spec = Supervisor.child_spec({Agent, fn -> :ok end}, id: Agent)

    {:ok, child_spec, %{stats_counter: Stats.init(telemetry_prefix)}}
  end

  ## Knock.Nebulex.Adapter.KV

  @impl true
  def fetch(_adapter_meta, key, opts) do
    with_hooks(opts, wrap_error(Knock.Nebulex.KeyError, key: key))
  end

  @impl true
  def put(_, _, _, _, _, _, opts) do
    with_hooks(opts, {:ok, true})
  end

  @impl true
  def put_all(_, _, _, _, opts) do
    with_hooks(opts, {:ok, true})
  end

  @impl true
  def delete(_, _, opts) do
    with_hooks(opts, :ok)
  end

  @impl true
  def take(_adapter_meta, key, opts) do
    with_hooks(opts, wrap_error(Knock.Nebulex.KeyError, key: key))
  end

  @impl true
  def has_key?(_, _, opts) do
    with_hooks(opts, {:ok, false})
  end

  @impl true
  def ttl(_adapter_meta, key, opts) do
    with_hooks(opts, wrap_error(Knock.Nebulex.KeyError, key: key))
  end

  @impl true
  def expire(_, _, _, opts) do
    with_hooks(opts, {:ok, false})
  end

  @impl true
  def touch(_, _, opts) do
    with_hooks(opts, {:ok, false})
  end

  @impl true
  def update_counter(_, _, amount, default, _, opts) do
    with_hooks(opts, {:ok, default + amount})
  end

  ## Knock.Nebulex.Adapter.Queryable

  @impl true
  def execute(adapter_meta, query_spec, opts)

  def execute(_, %{op: :get_all}, opts) do
    with_hooks(opts, {:ok, []})
  end

  def execute(_, _, opts) do
    with_hooks(opts, {:ok, 0})
  end

  @impl true
  def stream(_, _, opts) do
    with_hooks(opts, {:ok, Stream.each([], & &1)})
  end

  ## Knock.Nebulex.Adapter.Transaction

  @impl true
  def transaction(_, fun, opts) do
    with_hooks(opts, {:ok, fun.()})
  end

  @impl true
  def in_transaction?(_, opts) do
    with_hooks(opts, {:ok, false})
  end

  ## Private functions

  defp with_hooks([], result) do
    result
  end

  defp with_hooks(opts, result) do
    opts = Options.validate_runtime_shared_opts!(opts)

    if pre_hook = Keyword.get(opts, :before) do
      pre_hook.()
    end

    if post_hook = Keyword.get(opts, :after_return) do
      post_hook.(result)
    else
      result
    end
  end
end
