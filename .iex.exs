emails = [
  "hello@world.com",
  "hola@world.com",
  "nihao@world.com",
  "konnichiwa@world.com",
]

pages = [
  "google.com",
  "facebook.com",
  "apple.com",
  "netflix.com",
  "amazon.com"
]

good_job = fn ->
  Process.sleep(5_000)
  {:ok, []}
end

import_job = fn ->
  Process.sleep(60_000)
  {:ok, []}
end

bad_job = fn ->
  Process.sleep(5_000)
  :error
end

doomed_job = fn ->
  Process.sleep(5_000)
  raise "Boom!"
end

send_messages = fn num_messages ->
  with {:ok, conn} <- AMQP.Connection.open(),
       {:ok, channel} <- AMQP.Channel.open(conn) do
    Enum.each(1..num_messages//1, fn _ ->
      event = Enum.random(["cinema", "musical", "play"])
      user_id = Enum.random(1..3)
      AMQP.Basic.publish(channel, "", "bookings_queue", "#{event},#{user_id}")
    end)

    AMQP.Connection.close(conn)
  end
end
