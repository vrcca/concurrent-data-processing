defmodule Cdp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    job_runner_config = [
      strategy: :one_for_one,
      name: Jobber.JobRunner,
      max_seconds: 30_000
    ]

    children = [
      {Task.Supervisor, name: Sender.EmailTaskSupervisor},
      {DynamicSupervisor, job_runner_config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cdp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
