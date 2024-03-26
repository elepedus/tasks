defmodule Tasks.JobsTest do
  use Tasks.DataCase

  alias Tasks.Jobs

  describe "jobs" do
    alias Tasks.Jobs.Job

    import Tasks.JobsFixtures

    @invalid_attrs %{timeout: nil, priority: nil, status: nil, payload: nil, queue_id: nil, retries_left: nil, leased_until: nil}

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{timeout: 42, priority: 42, payload: %{}, queue_id: "some queue_id", retries_left: 42}

      assert {:ok, %Job{} = job} = Jobs.create_job(valid_attrs)
      assert job.timeout == 42
      assert job.priority == 42
      assert job.payload == %{}
      assert job.queue_id == "some queue_id"
      assert job.retries_left == 42
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      update_attrs = %{timeout: 43, priority: 43, payload: %{}, queue_id: "some updated queue_id", retries_left: 43}

      assert {:ok, %Job{} = job} = Jobs.update_job(job, update_attrs)
      assert job.timeout == 43
      assert job.priority == 43
      assert job.payload == %{}
      assert job.queue_id == "some updated queue_id"
      assert job.retries_left == 43
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end
