defmodule Scraper.OnlinePageProducerConsumer do
  require Logger
  use GenStage
  alias Scraper.PageProducer

  def start_link(id) do
    initial_state = []
    GenStage.start_link(__MODULE__, initial_state, name: via(id))
  end

  defp via(id), do: {:via, Registry, {ProducerConsumerRegistry, id}}

  def init(initial_state) do
    Logger.info("OnlinePageProducerConsumer init")

    producers = [
      {PageProducer, min_demand: 0, max_demand: 1}
    ]

    {:producer_consumer, initial_state, subscribe_to: producers}
  end

  def handle_events(events, _from, state) do
    Logger.info("OnlinePageProducerConsumer received #{inspect(events)}")
    online_events = Enum.filter(events, &Scraper.online?/1)
    {:noreply, online_events, state}
  end
end
