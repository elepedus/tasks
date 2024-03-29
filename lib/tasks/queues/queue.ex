defmodule Tasks.Queues.Queue do
  @enforce_keys [:id, :module, :interval, :workers]
  defstruct [:id, :module, :interval, :workers]
end