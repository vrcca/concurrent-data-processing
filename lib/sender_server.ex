defmodule SendServer do
  use GenServer

  def init(args) do
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    Process.send_after(self(), :retry, _in_5s = 5000)
    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send, email}, state) do
    status =
      case Sender.send_email(email) do
        {:ok, "email_sent"} -> "sent"
        :error -> "failed"
      end

    emails = [%{email: email, status: status, retries: 0} | state.emails]
    {:noreply, %{state | emails: emails}}
  end

  def handle_info(:retry, state = %{emails: emails, max_retries: max_retries}) do
    updated_emails =
      Enum.map(emails, fn
        failed = %{status: "failed", retries: retries, email: email} when retries < max_retries ->
          IO.puts("Retrying email #{email}...")

          new_status =
            case Sender.send_email(email) do
              {:ok, "email_sent"} -> "sent"
              :error -> "failed"
            end

          %{failed | retries: retries + 1, status: new_status}

        other ->
          other
      end)

    Process.send_after(self(), :retry, _in_5s = 5000)

    {:noreply, %{state | emails: updated_emails}}
  end

  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end
end
