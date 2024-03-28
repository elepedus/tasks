# Tasks

## Description
This is a very simple asynchronous task runner. It exposes two HTTP endpoints:

```
GET /api/jobs 
Returns a list of jobs present in the system

curl -X GET --location "http://localhost:4000/api/jobs" 
 
POST /api/jobs
Create a new job

curl -X POST --location "http://localhost:4000/api/jobs" \
    -H "Content-Type: application/json" \
    -d '{
          "job": {
            "queue_id": "fibonacci",
            "payload": {"n": 303}
          }
        }'   
```

Once submitted, jobs are saved in a Sqlite3 database. Queues are defined as simple Elixir modules with a `perform/1` function which returns a tuple of `{:ok, result}` or `{:error, description}`. Eg:
```elixir
defmodule Tasks.Queues.SleepyQueue do
  def perform(%{"duration" => duration}), do: {:ok, Process.sleep(duration)}
  def perform(_), do: {:error, :invalid_payload}
end
```
In order to enable the new queue, add it to `lib/tasks/queues.ex` eg:
```elixir
@queues [
    %{id: "fibonacci", module: Tasks.Queues.FibonacciQueue, interval: 1000, workers: 3},
    %{id: "sleeper", module: Tasks.Queues.SleepyQueue, interval: 1000, workers: 3}
  ]
```
Each queue will spawn the specified number of workers, which will query the database for available jobs at the specified interval. When a worker picks up a job, it creates a lease, so as to prevent the same job from being picked up by multiple workers.
Since each worker only picks up one job at a time, the worker count effectively controls the maximum concurrency limit for each queue.

## Running The Server
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Extension Possibilities
1. Automated Testing: This submission is sadly lacking in automated tests. Resolving this should be a top priority
2. Documentation: The key modules and functions should be documented
3. Monitoring: The project doesn't implement any monitoring beyond the standard Phoenix functionality

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
