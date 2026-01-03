defmodule AutoGrandPremiumOutlet.Infra.Repositories.SaleRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.SaleRepository

  use Agent

  alias AutoGrandPremiumOutlet.Domain.Sale

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
      sale -> {:ok, sale}
    end
  end

  ## -------- CREATE --------

  @impl true
  def create(%Sale{} = sale) do
    Agent.update(@agent_name, fn state -> Map.put(state, sale.id, sale) end)
    {:ok, sale}
  end

  ## -------- UPDATE --------

  @impl true
  def update(%Sale{} = sale) do
    Agent.update(@agent_name, fn state -> Map.put(state, sale.id, sale) end)
    {:ok, sale}
  end
end
