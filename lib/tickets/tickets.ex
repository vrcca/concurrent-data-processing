defmodule Tickets.Tickets do
  require Logger

  @users [
    %{id: "1", email: "foo@email.com"},
    %{id: "2", email: "bar@email.com"},
    %{id: "3", email: "baz@email.com"}
  ]

  def tickets_available?(event) do
    sleep(100..200)
    event != "cinema"
  end

  def create_ticket(_user, _event), do: sleep(250..1000)

  def send_email(user) do
    sleep(100..250)
    Logger.info("Sent email to #{inspect(user)}")
  end

  def users_by_ids(ids) when is_list(ids) do
    sleep(10..100)
    Enum.filter(@users, &(&1.id in ids))
  end

  defp sleep(range), do: Process.sleep(Enum.random(range))
end
