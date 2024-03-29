defmodule Tasks.Queues.SleepyQueue do
  @moduledoc """
  A queue which sleeps for the specified duration
  """

  @doc """
  Sleeps for the specified duration

  Returns `{:ok,:ok}` or `{:error, :invalid_payload}`
  ## Examples
  iex> Tasks.Queues.SleepyQueue.perform(%{"duration" => 1})
  {:ok,:ok}

  iex> Tasks.Queues.SleepyQueue.perform(%{})
  {:error, :invalid_payload}
  """
  def perform(map_with_duration)
  def perform(%{"duration" => duration}), do: {:ok, Process.sleep(duration)}
  def perform(_), do: {:error, :invalid_payload}
end
