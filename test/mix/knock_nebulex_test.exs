defmodule Mix.KnockNebulexTest do
  use ExUnit.Case, async: true

  import Mimic, only: [expect: 3]
  import Mix.KnockNebulex

  test "fail because umbrella project" do
    Mix.Project
    |> expect(:umbrella?, fn -> true end)

    assert_raise Mix.Error, ~r"Cannot run task", fn ->
      no_umbrella!("nebulex.gen.cache")
    end
  end
end
