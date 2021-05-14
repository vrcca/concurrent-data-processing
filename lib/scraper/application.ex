defmodule Scraper.Application do
  use Supervisor
  alias Scraper.PageProducer
  alias Scraper.OnlinePageProducerConsumer
  alias Scraper.PageConsumerSupervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl Supervisor
  def init(_args) do
    children = [
      PageProducer,
      PageConsumerSupervisor,
      OnlinePageProducerConsumer
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
