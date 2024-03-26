defmodule Tasks.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tasks.Jobs` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        payload: %{},
        priority: 42,
        queue_id: "some queue_id",
        retries_left: 42,
        timeout: 42
      })
      |> Tasks.Jobs.create_job()

    job
  end
end
