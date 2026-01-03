defmodule AutoGrandPremiumOutlet.Infra.Repositories.VehicleRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  use Agent

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  @agent_name __MODULE__

  ## -------- Agent Lifecycle --------

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: @agent_name)
  end

  ## -------- GET --------

  @impl true
  def get(id) do
    case Agent.get(@agent_name, fn state -> Map.get(state, id) end) do
      nil -> {:error, :not_found}
      vehicle -> {:ok, vehicle}
    end
  end

  ## -------- LIST --------

  @impl true
  def list_available_ordered_by_price do
    vehicles =
      Agent.get(@agent_name, fn state -> Map.values(state) end)
      |> Enum.filter(&(&1.status == :available))
      |> Enum.sort_by(& &1.price)

    {:ok, vehicles}
  end

  @impl true
  def list_sold do
    vehicles =
      Agent.get(@agent_name, fn state -> Map.values(state) end)
      |> Enum.filter(&(&1.status == :sold))
      |> Enum.sort_by(& &1.price)

    {:ok, vehicles}
  end

  ## -------- CREATE --------

  @impl true
  def save(%Vehicle{} = vehicle) do
    Agent.update(@agent_name, fn state -> Map.put(state, vehicle.id, vehicle) end)
    {:ok, vehicle}
  end

  ## -------- UPDATE --------

  @impl true
  def update(%Vehicle{} = vehicle) do
    Agent.update(@agent_name, fn state -> Map.put(state, vehicle.id, vehicle) end)
    {:ok, vehicle}
  end
end
