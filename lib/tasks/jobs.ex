defmodule Tasks.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Tasks.Repo

  alias Tasks.Jobs.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  def start(%Job{} = job) do
    job
    |> Job.transition(%{status: "in progress"})
    |> Job.update_lease(%{leased_until: DateTime.now!("Etc/UTC") |> DateTime.add(job.timeout, :millisecond)})
    |> dbg()
    |> Repo.update()
  end

  def done(%Job{} = job, result) do
    job
    |> Job.transition(%{status: "done"})
    |> Job.clear_lease()
    |> Job.result(%{result: result})
    |> dbg()
    |> Repo.update()
  end

  def failed(%Job{retries_left: r} = job, result) when r > 0 do
    job
    |> Job.strike(%{retries_left: r - 1})
    |> Job.transition(%{status: "submitted"})
    |> Job.result(%{result: result})
    |> Job.clear_lease()
    |> dbg()
    |> Repo.update()
  end
  def failed(%Job{} = job, result)do
    job
    |> Job.strike(%{retries_left: 0})
    |> Job.transition(%{status: "failed"})
    |> Job.result(%{result: result})
    |> Job.clear_lease()
    |> dbg()
    |> Repo.update()
  end
end
