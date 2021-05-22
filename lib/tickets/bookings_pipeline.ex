defmodule Tickets.BookingsPipeline do
  use Broadway
  require Logger

  alias Tickets.Tickets

  # Run `docker-compose -up -d` before testing this file
  @producer BroadwayRabbitMQ.Producer
  @producer_config [
    queue: "bookings_queue",
    declare: [durable: true],
    on_failure: :reject_and_requeue
  ]

  def start_link(_args) do
    options = [
      name: __MODULE__,
      producer: [module: {@producer, @producer_config}],
      processors: [
        default: []
      ],
      batchers: [
        cinema: [],
        musical: [],
        default: []
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def prepare_messages(messages, _context) do
    messages =
      Enum.map(messages, fn message ->
        Broadway.Message.update_data(message, fn data ->
          [event, user_id] = String.split(data, ",")
          %{event: event, user_id: user_id}
        end)
      end)

    users = Tickets.users_by_ids(Enum.map(messages, & &1.data.user_id))

    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        user = Enum.find(users, &(&1.id == data.user_id))
        Map.put(data, :user, user)
      end)
    end)
  end

  def handle_message(_processor, message, _context) do
    %{data: %{event: event}} = message

    if Tickets.tickets_available?(event) do
      case event do
        "cinema" ->
          Broadway.Message.put_batcher(message, :cinema)

        "musical" ->
          Broadway.Message.put_batcher(message, :musical)

        _other ->
          message
      end
    else
      Broadway.Message.failed(message, "bookings-closed")
    end
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    log("Batches!", batch_key: batch_info.batch_key, batcher: batch_info.batcher)

    messages
    |> Tickets.insert_all_tickets()
    |> tap(fn messages ->
      messages
      |> Enum.map(fn %{data: %{user: user}} -> user end)
      |> Enum.uniq()
      |> Enum.each(&Tickets.send_email/1)
    end)
  end

  def handle_failed(messages, _context) do
    log("Failed messages", events: messages)

    Enum.map(messages, fn
      %{status: {:failed, "bookings-closed"}} = message ->
        Broadway.Message.configure_ack(message, on_failure: :reject)

      message ->
        message
    end)
  end

  def log(message, data \\ []) do
    Logger.info([process: self(), message: message] ++ data)
  end
end
