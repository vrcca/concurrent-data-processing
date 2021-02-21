defmodule Jobber do
  alias Jobber.JobRunner
  alias Jobber.JobSupervisor

  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
  end

  def running_imports() do
    id = :"$1"
    pid = :"$2"
    type = :"$3"
    match_all = {id, pid, type}
    guards = [{:==, type, "import"}]
    map_result = [%{id: id, pid: pid, type: type}]
    Registry.select(Jobber.JobRegistry, [{match_all, guards, map_result}])
  end
end
