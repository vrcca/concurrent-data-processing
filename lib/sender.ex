defmodule Sender do
  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    Enum.each(emails, fn email ->
      Task.start(fn -> send_email(email) end)
    end)
  end
end
