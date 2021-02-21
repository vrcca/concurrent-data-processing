defmodule Jobber.Application do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl Supervisor
  def init(_args) do
    job_runner_config = [
      strategy: :one_for_one,
      name: Jobber.JobRunner,
      max_seconds: 30
    ]

    children = [
      {DynamicSupervisor, job_runner_config},
      {Registry, keys: :unique, name: Jobber.JobRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
