defmodule Mix.Tasks.Knock.Nbx do
  @shortdoc "Prints Nebulex help information"

  @moduledoc """
  Prints Nebulex tasks and their information.

      mix nbx

  """

  use Mix.Task

  alias Mix.Tasks.Help

  @impl true
  def run(args) do
    {_opts, args} = OptionParser.parse!(args, strict: [])

    case args do
      [] -> general()
      _ -> Mix.raise("Invalid arguments, expected: mix nbx")
    end
  end

  defp general do
    _ = Application.ensure_all_started(:knock_nebulex)

    Mix.shell().info("Knock Nebulex v#{Knock.Nebulex.vsn()}")
    Mix.shell().info("In-Process and Distributed Cache Toolkit for Elixir.")
    Mix.shell().info("\nAvailable tasks:\n")
    Help.run(["--search", "nbx."])
  end
end
