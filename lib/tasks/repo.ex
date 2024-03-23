defmodule Tasks.Repo do
  use Ecto.Repo,
    otp_app: :tasks,
    adapter: Ecto.Adapters.SQLite3
end
