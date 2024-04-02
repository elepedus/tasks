defmodule Tasks.Worker do
  @moduledoc """
  A generic worker process that polls for jobs matching the specified queue, runs them, and saves the results.
  """

  use GenServer
  import Ecto.Query
  alias Tasks.Jobs.Job
  alias Tasks.Jobs
  alias Tasks.Repo
  alias Tasks.Queues.Queue

  def start_link(%Queue{} = queue, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, queue, name: name)
  end

  @impl true
  def init(%Queue{} = queue) do
    schedule_tick(queue.interval)
    {:ok, %{queue: queue}}
  end

  @impl true
  def handle_info({:tick, delay}, state) do
    process(state)

    schedule_tick(delay)
    {:noreply, state}
  end

  defp schedule_tick(delay) do
    Process.send_after(self(), {:tick, delay}, delay)
  end

  defp process(%{queue: %Queue{} = queue}) do
    query =
      from j in Job,
        where: j.queue_id == ^queue.id,
        where: j.status == "submitted",
        where: is_nil(j.leased_until) or j.leased_until < ^DateTime.now!("Etc/UTC"),
        order_by: [asc: j.priority]

    query
    |> Ecto.Query.first()
    |> Repo.one()
    |> process_job(queue.module)
  end

  defp process_job(job, _) when is_nil(job), do: nil

  defp process_job(%Job{payload: payload, timeout: timeout} = job, module) do
    task =
      Task.Supervisor.async_nolink(Tasks.TaskSupervisor, fn ->
        job
        |> Jobs.start_job()

        module.perform(payload)
      end)

    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, result} ->
        handle_result(job, result)

      nil ->
        handle_timeout(job)
    end
  end

  defp handle_result(job, {:ok, response}) do
    job
    |> Jobs.complete_job(%{success: response})
  end

  defp handle_result(job, {:error, error}) do
    job
    |> Jobs.fail_job(%{error: error})
  end

  defp handle_timeout(job) do
    job
    |> Jobs.fail_job(%{error: "Timed out after #{job.timeout}ms"})

    nil
  end
end
