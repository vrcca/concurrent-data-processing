defmodule Tickets.Application do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(_args) do
    children = [Tickets.BookingsPipeline]
    opts = [strategy: :one_for_one, name: Tickets.Supervisor]
    Supervisor.init(children, opts)
  end
end
