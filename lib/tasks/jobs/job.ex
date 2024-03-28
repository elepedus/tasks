defmodule Tasks.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "jobs" do
    field :timeout, :integer, default: 1000
    field :priority, :integer, default: 0
    field :status, :string, default: "submitted"
    field :payload, :map, default: %{}
    field :queue_id, :string
    field :retries_left, :integer, default: 3
    field :leased_until, :utc_datetime, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:queue_id, :payload, :priority, :retries_left, :timeout])
    |> validate_required([:queue_id, :priority, :retries_left, :timeout])
  end

  def transition(job, attrs) do
    job
    |> cast(attrs, [:status], force_changes: true)
    |> validate_required([:status])
  end

  def strike(job, attrs) do
    job
    |> cast(attrs, [:retries_left])
    |> validate_required([:retries_left])
  end

  def update_lease(job, attrs) do
    job
    |> cast(attrs, [:leased_until])
    |> validate_required([:leased_until])
  end

  def clear_lease(job) do
    job
    |> force_change(:leased_until, nil)
  end
end
