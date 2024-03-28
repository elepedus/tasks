defmodule TasksWeb.JobJSON do
  alias Tasks.Jobs.Job

  @doc """
  Renders a list of jobs.
  """
  def index(%{jobs: jobs}) do
    %{data: for(job <- jobs, do: data(job))}
  end

  @doc """
  Renders a single job.
  """
  def show(%{job: job}) do
    %{data: data(job)}
  end

  defp data(%Job{} = job) do
    %{
      id: job.id,
      queue_id: job.queue_id,
      payload: job.payload,
      priority: job.priority,
      status: job.status,
      retries_left: job.retries_left,
      timeout: job.timeout,
      leased_until: job.leased_until,
      result: job.result
    }
  end
end
