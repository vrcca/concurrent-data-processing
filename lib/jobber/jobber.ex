defmodule Jobber do
  alias Jobber.JobRunner
  alias Jobber.JobSupervisor

  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
  end
end
