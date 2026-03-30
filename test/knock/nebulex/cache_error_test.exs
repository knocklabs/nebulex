defmodule Knock.Nebulex.CacheErrorTest do
  use ExUnit.Case, async: true

  # Inherit error tests
  use Knock.Nebulex.Cache.KVErrorTest
  use Knock.Nebulex.Cache.KVExpirationErrorTest
  use Knock.Nebulex.Cache.QueryableErrorTest

  import Mimic, only: [verify_on_exit!: 1, stub: 3]

  setup [:verify_on_exit!, :setup_cache]

  describe "put!/3" do
    test "raises an error due to a timeout", %{cache: cache} do
      assert_raise Knock.Nebulex.Error, ~r/command execution timed out/, fn ->
        cache.put!(:error, :timeout)
      end
    end

    test "raises an error due to RuntimeError", %{cache: cache} do
      msg =
        Regex.escape(
          "the following exception occurred when executing a command.\n\n" <>
            "    ** (RuntimeError) runtime error\n"
        )

      assert_raise Knock.Nebulex.Error, ~r/#{msg}/, fn ->
        cache.put!(:error, %RuntimeError{})
      end
    end
  end

  describe "fetch_or_store/3" do
    test "returns an error due to a cache command failure", %{cache: cache} do
      assert cache.fetch_or_store(:error, fn -> {:ok, "value"} end) ==
               {:error, %Knock.Nebulex.Error{reason: :error}}
    end
  end

  defp setup_cache(_ctx) do
    Knock.Nebulex.Cache.Registry
    |> stub(:lookup, fn _ ->
      %{adapter: Knock.Nebulex.FakeAdapter, telemetry: true, telemetry_prefix: [:knock_nebulex, :test]}
    end)

    {:ok, cache: Knock.Nebulex.TestCache.Cache, name: __MODULE__}
  end
end
