defmodule Tasks.Queues do
  @moduledoc """
    The Queues context
  """
  use Supervisor
  alias Tasks.Queues.Queue

  @queues [
    %Queue{id: "fibonacci", module: Tasks.Queues.FibonacciQueue, interval: 1000, workers: 3},
    %Queue{id: "sleeper", module: Tasks.Queues.SleepyQueue, interval: 1000, workers: 3}
  ]

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = child_spec()
    Supervisor.init(children, strategy: :one_for_all)
  end

  def child_spec() do
    @queues
    |> Enum.flat_map(fn queue ->
      1..queue.workers
      |> Enum.map(fn index ->
        id = "#{queue.id}_queue_worker_number_#{index}" |> String.to_atom()

        %{
          id: id,
          start: {Tasks.Worker, :start_link, [queue, id]}
        }
      end)
    end)
  end
end
