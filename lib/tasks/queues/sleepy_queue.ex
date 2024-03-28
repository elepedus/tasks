defmodule Tasks.Queues.SleepyQueue do
  def perform(%{"duration" => duration}), do: {:ok, Process.sleep(duration)}
  def perform(_), do: {:error, :invalid_payload}
end
