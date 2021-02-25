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
      {Registry, keys: :unique, name: ProducerConsumerRegistry},
      PageProducer,
      producer_consumer_spec(id: 1),
      producer_consumer_spec(id: 2),
      PageConsumerSupervisor
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end

  defp producer_consumer_spec(id: id) do
    id = "online_page_producer_consumer_#{id}"
    Supervisor.child_spec({OnlinePageProducerConsumer, [id]}, id: id)
  end
end
