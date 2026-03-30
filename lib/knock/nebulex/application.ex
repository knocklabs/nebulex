defmodule Knock.Nebulex.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Knock.Nebulex.Cache.Registry
    ]

    opts = [strategy: :one_for_one, name: Knock.Nebulex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
