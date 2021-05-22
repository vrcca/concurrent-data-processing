defmodule Tickets.Tickets do
  @users [
    %{id: "1", email: "foo@email.com"},
    %{id: "2", email: "bar@email.com"},
    %{id: "3", email: "baz@email.com"}
  ]

  def tickets_available?(_event) do
    sleep(100..200)
    true
  end

  def create_ticket(_user, _event), do: sleep(250..1000)

  def insert_all_tickets(messages) do
    count = Enum.count(messages)
    sleep(count..(count * 250))
    messages
  end

  def send_email(_user) do
    sleep(100..250)
  end

  def users_by_ids(ids) when is_list(ids) do
    sleep(10..100)
    Enum.filter(@users, &(&1.id in ids))
  end

  defp sleep(range), do: Process.sleep(Enum.random(range))
end
