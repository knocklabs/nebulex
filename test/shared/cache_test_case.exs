defmodule Knock.Nebulex.CacheTestCase do
  @moduledoc """
  Shared Tests
  """

  @default_tests [
    Knock.Nebulex.Cache.KVTest,
    Knock.Nebulex.Cache.KVExpirationTest,
    Knock.Nebulex.Cache.KVPropTest,
    Knock.Nebulex.Cache.QueryableTest,
    Knock.Nebulex.Cache.QueryableExpirationTest,
    Knock.Nebulex.Cache.QueryableQueryErrorTest,
    Knock.Nebulex.Cache.TransactionTest,
    Knock.Nebulex.Cache.ObservableTest
  ]

  defmacro __using__(opts) do
    only =
      opts
      |> Keyword.get(:only, @default_tests)
      |> Code.eval_quoted()
      |> elem(0)

    except =
      opts
      |> Keyword.get(:except, [])
      |> Code.eval_quoted()
      |> elem(0)

    for test <- only -- except do
      quote do
        use unquote(test)
      end
    end
  end
end
