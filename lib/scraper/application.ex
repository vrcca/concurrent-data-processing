defmodule Scraper.Application do
  use Supervisor
  alias Scraper.PageProducer
  alias Scraper.PageConsumer

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl Supervisor
  def init(_args) do
    children = [
      PageProducer,
      Supervisor.child_spec(PageConsumer, id: :consumer_a),
      Supervisor.child_spec(PageConsumer, id: :consumer_b)
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
