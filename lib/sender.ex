defmodule Sender do
  def send_email(_email = "konnichiwa@world.com") do
    :error
  end

  def send_email(email) do
    time = Enum.random(2_000..4_000)
    Process.sleep(time)
    IO.puts("Email to #{email} sent in #{time} milliseconds.")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream_nolink(emails, &send_email/1,
      max_concurrency: 2,
      ordered: false,
      timeout: 3_000,
      on_timeout: :kill_task
    )
    |> Enum.to_list()
  end
end
