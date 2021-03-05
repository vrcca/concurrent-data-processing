defmodule Airports.Application do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(_args) do
    children = []
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
