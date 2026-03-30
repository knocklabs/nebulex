defmodule Knock.Nebulex.Cache.QueryableQueryErrorTest do
  import Knock.Nebulex.CacheCase

  deftests do
    describe "get_all/2 error:" do
      test "raises an exception because of an invalid query", %{cache: cache} do
        assert_raise Knock.Nebulex.QueryError, fn ->
          cache.get_all(query: :invalid)
        end
      end
    end

    describe "stream/2 error:" do
      test "raises an exception because of an invalid query", %{cache: cache} do
        assert_raise Knock.Nebulex.QueryError, fn ->
          cache.stream!(query: :invalid_query)
        end
      end
    end

    describe "delete_all/2 error:" do
      test "raises an exception because of an invalid query", %{cache: cache} do
        assert_raise Knock.Nebulex.QueryError, fn ->
          cache.delete_all(query: :invalid)
        end
      end
    end

    describe "count_all/2 error:" do
      test "raises an exception because of an invalid query", %{cache: cache} do
        assert_raise Knock.Nebulex.QueryError, fn ->
          cache.count_all(query: :invalid)
        end
      end
    end
  end
end
