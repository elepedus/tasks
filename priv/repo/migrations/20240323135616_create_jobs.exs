defmodule Tasks.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :queue_id, :string
      add :payload, :map
      add :priority, :integer
      add :status, :text
      add :retries_left, :integer
      add :timeout, :integer
      add :leased_until, :utc_datetime
      add :result, :map

      timestamps(type: :utc_datetime)
    end
  end
end
