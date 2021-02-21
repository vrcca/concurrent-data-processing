defmodule Scraper.Application do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl Supervisor
  def init(_args) do
    children = [
      Scraper.PageProducer,
      Scraper.PageConsumer
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
