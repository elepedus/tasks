defmodule Tasks.Queues.FibonacciQueue do
  @moduledoc """
  A simple queue which asynchronously computes numbers in the Fibonacci sequence.
  """

  @doc """
  Computes the `n`th number in the Fibonacci sequence.

  Returns `{:ok, number}` or `{:error, :invalid_payload}`

  ## Examples
  iex> Tasks.Queues.FibonacciQueue.perform(%{"n" => 1})
  {:ok, 1}

  iex> Tasks.Queues.FibonacciQueue.perform(%{"n" => 2})
  {:ok, 1}

  iex> Tasks.Queues.FibonacciQueue.perform(%{"n" => 3})
  {:ok, 2}

  iex> Tasks.Queues.FibonacciQueue.perform(%{"n" => -1})
  {:error, :invalid_payload}

  iex> Tasks.Queues.FibonacciQueue.perform(%{})
  {:error, :invalid_payload}
  """
  def perform(map_with_n)
  def perform(%{"n" => n}) when n >= 0, do: {:ok, fibonacci(n)}
  def perform(_), do: {:error, :invalid_payload}

  @doc """
  Computes the `n`th number in the Fibonacci sequence.

  Returns `number`

  ## Examples
  iex> Tasks.Queues.FibonacciQueue.fibonacci(1)
  1

  iex> Tasks.Queues.FibonacciQueue.fibonacci(2)
  1

  iex> Tasks.Queues.FibonacciQueue.fibonacci(3)
  2

  iex> Tasks.Queues.FibonacciQueue.fibonacci(-1)
  ** (ArgumentError) invalid input
  """
  def fibonacci(n) when n >= 0, do: fibonacci(n, 1, 0)
  def fibonacci(_), do: raise(ArgumentError, message: "invalid input")
  defp fibonacci(0, _, result), do: result
  defp fibonacci(n, next, result), do: fibonacci(n - 1, next + result, next)
end
