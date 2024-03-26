defmodule TasksWeb.JobControllerTest do
  use TasksWeb.ConnCase

  import Tasks.JobsFixtures

  alias Tasks.Jobs.Job

  @create_attrs %{
    timeout: 42,
    priority: 42,
    payload: %{},
    queue_id: "some queue_id",
    retries_left: 42,
  }
  @update_attrs %{
    timeout: 43,
    priority: 43,
    payload: %{},
    queue_id: "some updated queue_id",
    retries_left: 43,
  }
  @invalid_attrs %{timeout: nil, priority: nil, status: nil, payload: nil, queue_id: nil, retries_left: nil, leased_until: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all jobs", %{conn: conn} do
      conn = get(conn, ~p"/api/jobs")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create job" do
    test "renders job when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/jobs", job: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/jobs/#{id}")

      assert %{
               "id" => ^id,
               "leased_until" => nil,
               "payload" => %{},
               "priority" => 42,
               "queue_id" => "some queue_id",
               "retries_left" => 42,
               "status" => "submitted",
               "timeout" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/jobs", job: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update job" do
    setup [:create_job]

    test "renders job when data is valid", %{conn: conn, job: %Job{id: id} = job} do
      conn = put(conn, ~p"/api/jobs/#{job}", job: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/jobs/#{id}")

      assert %{
               "id" => ^id,
               "leased_until" => nil,
               "payload" => %{},
               "priority" => 43,
               "queue_id" => "some updated queue_id",
               "retries_left" => 43,
               "status" => "submitted",
               "timeout" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, job: job} do
      conn = put(conn, ~p"/api/jobs/#{job}", job: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete job" do
    setup [:create_job]

    test "deletes chosen job", %{conn: conn, job: job} do
      conn = delete(conn, ~p"/api/jobs/#{job}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/jobs/#{job}")
      end
    end
  end

  defp create_job(_) do
    job = job_fixture()
    %{job: job}
  end
end
