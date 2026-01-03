defmodule AutoGrandPremiumOutlet.Infra.Repositories.PaymentRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.PaymentRepository

  use Agent

  alias AutoGrandPremiumOutlet.Domain.Payment

  @agent_name __MODULE__

  ## -------- Agent Lifecycle --------

  def start_link(_opts) do
    Agent.start_link(
      fn -> %{by_id: %{}, by_code: %{}, by_sale_id: %{}} end,
      name: @agent_name
    )
  end

  ## -------- GET --------

  @impl true
  def get(id) do
    case Agent.get(@agent_name, fn state -> Map.get(state.by_id, id) end) do
      nil -> {:error, :not_found}
      payment -> {:ok, payment}
    end
  end

  @impl true
  def get_by_payment_code(code) do
    case Agent.get(@agent_name, fn state -> Map.get(state.by_code, code) end) do
      nil -> {:error, :not_found}
      payment -> {:ok, payment}
    end
  end

  @impl true
  def get_by_sale_id(sale_id) do
    case Agent.get(@agent_name, fn state -> Map.get(state.by_sale_id, sale_id) end) do
      nil -> {:error, :not_found}
      payment -> {:ok, payment}
    end
  end

  ## -------- CREATE --------

  @impl true
  def save(%Payment{} = payment) do
    Agent.update(@agent_name, fn state ->
      %{
        by_id: Map.put(state.by_id, payment.id, payment),
        by_code: Map.put(state.by_code, payment.payment_code, payment),
        by_sale_id: Map.put(state.by_sale_id, payment.sale_id, payment)
      }
    end)

    {:ok, payment}
  end

  ## -------- UPDATE --------

  @impl true
  def update(%Payment{} = payment) do
    Agent.update(@agent_name, fn state ->
      %{
        by_id: Map.put(state.by_id, payment.id, payment),
        by_code: Map.put(state.by_code, payment.payment_code, payment),
        by_sale_id: Map.put(state.by_sale_id, payment.sale_id, payment)
      }
    end)

    {:ok, payment}
  end
end
