defmodule Cdp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Sender.Application,
      Jobber.Application,
      Scraper.Application,
      Airports.Application,
      Tickets.Application
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cdp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
