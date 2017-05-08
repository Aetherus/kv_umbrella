defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: KV.Supervisor)
  end

  def init(:ok) do
    children = [
      worker(KV.Registry, [KV.Registry]),
      supervisor(KV.BucketSupervisor, []),
      supervisor(Task.Supervisor, [[name: KV.RouterTasks]])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
