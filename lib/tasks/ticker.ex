defmodule Tasks.Ticker do
  use GenServer
  import Ecto.Query
  alias Tasks.Jobs.Job
  alias Tasks.Jobs
  alias Tasks.Repo
  alias Tasks.Queues.FibonacciQueue

  @concurrency_limit 3

  @impl true
  def init(interval) do
    interval
    |> dbg

    schedule_tick(%{}, interval)

    {:ok,
     %{
       queues: %{
         "fibonacci" => Tasks.Queues.FibonacciQueue,
         "2f36a760-ac3d-4238-b1f5-bfa89c789cd5" => Tasks.Queues.SleepyQueue
       }
     }}
  end

  def schedule_tick(state, delay) do
    Process.send_after(self(), {:tick, delay}, delay)
  end

  def process(%{queues: queues, delay: delay}) do
    jobs =
      Repo.all(
        from j in Job,
          where: j.queue_id in ^Map.keys(queues),
          where: j.status == "submitted",
          where: is_nil(j.leased_until) or j.leased_until < ^DateTime.now!("Etc/UTC"),
          order_by: [asc: j.priority],
          limit: ^@concurrency_limit
      )
      |> dbg

    results =
      jobs
      |> Enum.map(fn %Job{payload: payload, timeout: timeout, queue_id: queue_id} = job ->
        task =
          Task.Supervisor.async_nolink(Tasks.TaskSupervisor, fn ->
            job
            |> Jobs.start()

            module = queues |> Map.get(queue_id)

            module.perform(payload)
          end)
      end)
      |> Task.yield_many(:infinity)

    Enum.zip(jobs, results)
    |> Enum.map(fn {job, {task, result}} = input ->
      input
      |> dbg()

      if is_nil(result) do
        Task.shutdown(task)

        job
        |> Jobs.failed(%{error: "Timed out after #{job.timeout}ms"})
      else
        case result do
          {:ok, {:ok, response}} ->
            job
            |> Jobs.done(%{success: response})

          {:ok, {:error, error}} ->
            job
            |> Jobs.failed(%{error: error})
        end
      end
      |> dbg()
    end)
  end

  @impl true
  def handle_call(request, from, state) do
    [request, from, state]
    |> dbg

    {:reply, from, state}
  end

  @impl true
  def handle_cast(request, state) do
    [request, state]
    |> dbg

    {:noreply, state}
  end

  @impl true
  def handle_info({:tick, delay}, state) when delay < 1, do: {:noreply, state}

  @impl true
  def handle_info({:tick, delay} = payload, state) do
    payload
    |> dbg

    process(Map.put(state, :delay, delay))

    schedule_tick(state, delay - 10)
    {:noreply, state}
  end
end
