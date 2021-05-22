defmodule Tickets.NotificationsPipeline do
  require Logger
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    queue: "notifications_queue",
    declare: [durable: true],
    on_failure: :reject_and_requeue,
    qos: [prefetch_count: 100]
  ]

  def start_link(_args) do
    options = [
      name: NotificationsPipeline,
      producer: [module: {@producer, @producer_config}],
      processors: [default: []],
      batchers: [
        email: [concurrency: 5, batch_timeout: _10_seconds = 10_000]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  @impl Broadway
  def prepare_messages(messages, _context) do
    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        [type, recipient] = String.split(data, ",")
        %{type: type, recipient: recipient}
      end)
    end)
  end

  @impl Broadway
  def handle_message(_processor, message, _context) do
    message
    |> Broadway.Message.put_batcher(:email)
    |> Broadway.Message.put_batch_key(message.data.recipient)
  end

  @impl Broadway
  def handle_batch(_batcher, messages, batch_info, _context) do
    log("Batch", batcher: batch_info.batcher, batch_key: batch_info.batch_key)
    messages
  end

  def log(message, data \\ []) do
    Logger.info([process: self(), message: message] ++ data)
  end
end
