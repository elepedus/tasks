defmodule Tasks.Queues.FibonacciQueue do
  def perform(%{"n" => n}) when n > 0, do: {:ok, fibonacci(n)}
  def perform(_), do: {:error, :invalid_payload}

  def fibonacci(n), do: fibonacci(n, 1, 0)
  defp fibonacci(0, _, result), do: result
  defp fibonacci(n, next, result), do: fibonacci(n - 1, next + result, next)
end
