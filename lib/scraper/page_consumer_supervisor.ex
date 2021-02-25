defmodule Scraper.PageConsumerSupervisor do
  use ConsumerSupervisor
  require Logger
  alias Scraper.PageConsumer
  alias Scraper.OnlinePageProducerConsumer

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args)
  end

  def init(_args) do
    Logger.info("PageConsumerSupervisor init")

    children = [
      %{id: PageConsumer, start: {PageConsumer, :start_link, []}, restart: :transient}
    ]

    producers = [{OnlinePageProducerConsumer, max_demand: 2}]
    opts = [strategy: :one_for_one, subscribe_to: producers]

    ConsumerSupervisor.init(children, opts)
  end
end
